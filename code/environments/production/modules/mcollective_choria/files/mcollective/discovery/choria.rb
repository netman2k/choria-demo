require "net/http"
require_relative "../util/choria"

module MCollective
  class Discovery
    class Choria
      def self.discover(filter, timeout, limit=0, client=nil)
        Choria.new(filter, timeout, limit, client).discover
      end

      attr_reader :filter, :timeout, :limit, :client, :config

      def initialize(filter, timeout, limit, client)
        @filter = filter
        @timeout = timeout
        @limit = limit
        @client = client
        @config = Config.instance
      end

      # Search for nodes
      #
      # @return [Array<String>] list of certnames found
      def discover
        queries = []

        if filter["fact"].empty? && filter["cf_class"].empty? && filter["agent"].empty? && filter["identity"].empty?
          queries << discover_nodes([])
        else
          queries << discover_collective(filter["collective"]) if filter["collective"]
          queries << discover_nodes(filter["identity"]) unless filter["identity"].empty?
          queries << discover_classes(filter["cf_class"]) unless filter["cf_class"].empty?
          queries << discover_facts(filter["fact"]) unless filter["fact"].empty?
          queries << discover_agents(filter["agent"]) unless filter["agent"].empty?
        end

        extract_certs(query(node_search_string(queries.compact)))
      end

      # Discovers nodes in a specific collective
      #
      # @param filter [String] a collective name
      # @return [String] a query string
      def discover_collective(filter)
        'certname in fact_contents[certname] {path ~> ["mcollective", "server", "collectives", "\\\\d"] and value = "%s"}' % filter
      end

      # Searches for facts
      #
      # Nodes are searched using an `and` operator via the discover_classes method
      #
      # When the `rpcutil` agent is required it will look for `Mcollective` class
      # otherwise `Mcollective_avent_agentname` thus it will only find plugins
      # installed using the `ripienaar/mcollective` AIO plugin packager
      #
      # @param filter [Array<String>] agent names
      # @return [Array<String>] list of nodes found
      def discover_agents(filter)
        pql = filter.map do |agent|
          if agent == "rpcutil"
            discover_classes(["mcollective::service"])
          elsif agent =~ /^\/(.+)\/$/
            'resources {type = "File" and tag ~ "mcollective_agent_.*?%s.*?_server"}' % [string_regexi($1)]
          else
            'resources {type = "File" and tag = "mcollective_agent_%s_server"}' % [agent]
          end
        end

        pql.join(" and ") unless pql.empty?
      end

      # Turns a string into a case insensitive regex string
      #
      # @param value [String]
      # @return [String]
      def string_regexi(value)
        value =~ /^\/(.+)\/$/ ? derived_value = $1 : derived_value = value.dup

        derived_value.each_char.map do |char|
          if char =~ /[[:alpha:]]/
            "[%s%s]" % [char.downcase, char.upcase]
          else
            char
          end
        end.join
      end

      # Capitalize a Puppet Resource
      #
      # foo::bar => Foo::Bar
      #
      # @param resource [String] a resource title
      # @return [String]
      def capitalize_resource(resource)
        resource.split("::").map(&:capitalize).join("::")
      end

      # Searches for facts
      #
      # Nodes are searched using an `and` operator
      #
      # @param filter [Array<Hash>] hashes with :fact, :operator and :value
      # @return [Array<String>] list of nodes found
      def discover_facts(filter)
        pql = filter.map do |q|
          fact = q[:fact]
          operator = q[:operator]
          value = q[:value]

          case operator
          when "=~"
            regex = string_regexi(value)

            'facts {name = "%s" and value ~ "%s"}' % [fact, regex]
          when "=="
            'facts {name = "%s" and value = "%s"}' % [fact, value]
          when "!="
            'facts {name = "%s" and !(value = "%s")}' % [fact, value]
          when ">=", ">", "<=", "<"
            if numeric?(value)
              'facts {name = "%s" and value %s %s}' % [fact, operator, value]
            else
              'facts {name = "%s" and value %s "%s"}' % [fact, operator, value]
            end
          else
            raise("Do not know how to do fact comparisons using operator `%s` using PuppetDB" % operator)
          end
        end

        pql.join(" and ") unless pql.empty?
      end

      # Searches for classes
      #
      # Nodes are searched using an `and` operator
      #
      # @return [Array<String>] list of nodes found
      def discover_classes(filter)
        pql = filter.map do |klass|
          if klass =~ /^\/(.+)\/$/
            'resources {type = "Class" and title ~ "%s"}' % [string_regexi($1)]
          else
            'resources {type = "Class" and title = "%s"}' % [capitalize_resource(klass)]
          end
        end

        pql.join(" and ") unless pql.empty?
      end

      # Searches for nodes
      #
      # Nodes are searched using an `or` operator
      #
      # @return [Array<String>] list of nodes found
      def discover_nodes(filter)
        if filter.empty?
          Log.debug("Empty node filter found, discovering all nodes")
          nil
        else
          pql = filter.map do |ident|
            if ident =~ /^\/(.+)\/$/
              'certname ~ "%s"' % string_regexi($1)
            else
              'certname = "%s"' % ident
            end
          end

          pql.join(" or ") unless pql.empty?
        end
      end

      # Extracts the certname from any active nodes in the node list
      #
      # @param nodes [Array] nodes list as produced by PuppetDB
      # @return [Array<String>] list of certificate names
      def extract_certs(nodes)
        nodes.map {|n| n["certname"]}.compact
      end

      # Produce a nodes query with the supplied sub query included
      #
      # @param queries [Array<String>] PQL queries to be used as a sub query
      # @return [String] nodes search string
      def node_search_string(queries)
        filter_queries = queries.map {|q| "(%s)" % q}.join(" and ")

        "nodes[certname, deactivated] { %s }" % [filter_queries]
      end

      # Determines if a string is a number, either float or integer
      #
      # @param string [String]
      # @return [boolean]
      def numeric?(string)
        true if Float(string) rescue false
      end

      # Creates a JSON accepting Net::HTTP::Get instance for a path
      #
      # @param path [String]
      # @return [Net::HTTP::Get]
      def http_get(path)
        Net::HTTP::Get.new(path, "accept" => "application/json")
      end

      # Performs a PQL query against PuppetDB
      #
      # @param pql [String] PQL query
      # @return [Hash,Array] JSON parsed result set from PuppetDB
      # @raise [StandardError] when querying fails
      def query(pql)
        Log.debug("Performing PQL query: %s" % pql)

        path = "/pdb/query/v4?%s" % URI.encode_www_form("query" => pql)

        resp, data = https.request(http_get(path))

        raise("Failed to make request to PuppetDB: %s: %s: %s" % [resp.code, resp.message, resp.body]) unless resp.code == "200"

        JSON.parse(data || resp.body)
      end

      def choria
        @_choria ||= Util::Choria.new("production", nil, false)
      end

      # (see Util::Choria#https)
      def https
        @_https ||= begin
                      choria.check_ssl_setup
                      choria.https(choria.puppetdb_server)
                    end
      end
    end
  end
end
