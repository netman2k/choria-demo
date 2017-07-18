class mcollective_agent_package (
  String $config_name,
  Array[String] $client_files = [],
  Array[String] $client_directories = [],
  Array[String] $server_files = [],
  Array[String] $server_directories = [],
  Array[String] $common_files = [],
  Array[String] $common_directories = [],
  Boolean $manage_gem_dependencies = true,
  Hash $gem_dependencies = {},
  Boolean $manage_package_dependencies = true,
  Hash $package_dependencies = {},
  Boolean $manage_class_dependencies = true,
  Array[String] $class_dependencies = [],
  Mcollective::Policy_action $policy_default = $mcollective::policy_default,
  Array[Mcollective::Policy] $policies = [],
  Hash $config = {},
  Hash $client_config = {},
  Hash $server_config = {},
  Boolean $client = $mcollective::client,
  Boolean $server = $mcollective::server,
  Enum["present", "absent"] $ensure = "present"
) {
  mcollective::module_plugin{$name:
    config_name                 => $config_name,
    client_files                => $client_files,
    server_files                => $server_files,
    common_files                => $common_files,
    client_directories          => $client_directories,
    server_directories          => $server_directories,
    common_directories          => $common_directories,
    gem_dependencies            => $gem_dependencies,
    manage_gem_dependencies     => $manage_gem_dependencies,
    package_dependencies        => $package_dependencies,
    manage_package_dependencies => $manage_package_dependencies,
    class_dependencies          => $class_dependencies,
    policy_default              => $policy_default,
    policies                    => $policies,
    config                      => $config,
    client_config               => $client_config,
    server_config               => $server_config,
    client                      => $client,
    server                      => $server,
    ensure                      => $ensure
  }
}
