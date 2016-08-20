class nats (
  Optional[String] $routes_password = undef,
  Array[String] $servers = [],
  String $client_port = "4222",
  String $monitor_port = "8222",
  String $cluster_port = "4223",
  Boolean $debug = false,
  Boolean $trace = false,
  Boolean $announce_cluster = false,
  String $binpath = "/usr/sbin/gnatsd",
  String $configdir = "/etc/gnatsd",
  String $piddir = "/var/run",
  String $binary_source = "puppet:///modules/nats/gnatsd-0.9.4",
  String $service_name = "gnatsd",
  String $cert_file = "/etc/puppetlabs/puppet/ssl/certs/${facts['networking']['fqdn']}.pem",
  String $key_file = "/etc/puppetlabs/puppet/ssl/private_keys/${facts['networking']['fqdn']}.pem",
  String $ca_file = "/etc/puppetlabs/puppet/ssl/certs/ca.pem",
  Boolean $manage_collectd = false
) {
  if $servers.empty or $facts["networking"]["fqdn"] in $servers {
    if SemVer.new($facts["aio_agent_version"]) < SemVer.new("1.5.2") {
      fail("Puppet AIO Agent 1.5.2 or newer is needed by the ripienaar/nats module")
    }

    $peers = $servers.filter |$s| { $s != $facts["networking"]["fqdn"] }

    include nats::install
    include nats::config
    include nats::service

    if $manage_collectd {
      include nats::collectd
    }
  } else {
    fail(sprintf("%s is not in the list of NATS servers %s", $facts["networking"]["fqdn"], $servers.join(", ")))
  }
}
