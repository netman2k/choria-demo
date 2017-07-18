# @instances [Integer] How many federation brokers to run on this node
# @stats_base_port [Integer] When not 0 start listening for stats on HTTP on this and every consecutive port for every instance
# @federation_middleware_hosts [Array[$string]] host:port pairs for the federstion middleware when not using SRV records
# @collective_middleware_hosts [Array[$string]] host:port pairs for the collective middleware when not using SRV records
# @srv_domain [String] the domain to find SRV records in for this broker
# @randomize_middleware_hosts [Boolean] Randomize configured or discovered middleware hosts
# @log_level ["debug", "info", "warn"] MCollective log level
# @ensure ["absent", "present"]
define mcollective_choria::federation_broker (
  Integer $instances = 1,
  Integer $stats_base_port = 0,
  Array[String] $federation_middleware_hosts = [],
  Array[String] $collective_middleware_hosts = [],
  String $srv_domain = $facts["networking"]["domain"],
  Boolean $randomize_middleware_hosts = false,
  Enum["debug", "info", "warn"] $log_level = "info",
  Enum["present", "absent"] $ensure = "present"
) {
  range(1, $instances).each |$instance| {
    $config_file = "${mcollective::configdir}/federation/${name}_${instance}.cfg"
    $log_file = "/var/log/puppetlabs/mcollective-federation_${name}_${instance}.log"

    if $stats_base_port == 0 {
      $stats_port = 0
    } else {
      $stats_port = $stats_base_port + $instance - 1
    }

    if $ensure == "present" {
      $config = epp("mcollective_choria/federation_config.epp", {
        "cluster"                     => $name,
        "instance"                    => $instance,
        "stats_port"                  => $stats_port,
        "federation_middleware_hosts" => $federation_middleware_hosts,
        "collective_middleware_hosts" => $collective_middleware_hosts,
        "srv_domain"                  => $srv_domain,
        "log_file"                    => $log_file,
        "log_level"                   => $log_level,
        "randomize_middleware_hosts"  => $randomize_middleware_hosts
      })

      mcollective::config_file{$config_file:
        owner   => $mcollective::plugin_owner,
        group   => $mcollective::plugin_group,
        mode    => $mcollective::plugin_mode,
        content => $config,
        notify  => Service["federation_broker@${name}_${instance}"]
      } ->

      systemd::unit_file{"federation_broker@${name}_${instance}.service":
        source => "puppet:///modules/mcollective_choria/federation_broker.service"
      } ->

      service{"federation_broker@${name}_${instance}":
        enable    => true,
        ensure    => running,
        subscribe => Class["mcollective::service"]
      }
    } else {
      service{"federation_broker@${name}_${instance}":
        ensure => "stopped"
      } ->

      systemd::unit_file{"federation_broker@${name}_${instance}.service":
        ensure => "absent"
      } ->

      mcollective::config_file{$config_file:
        ensure => "absent"
      }
    }
  }
}
