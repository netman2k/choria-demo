# mcollective_agent_puppet version 1.11.1

#### Table of Contents

1. [Overview](#overview)
1. [Usage](#usage)
1. [Configuration](#configuration)

## Overview

Run Puppet agent, get its status, and enable/disable it

The mcollective_agent_puppet module is based on the source from http://puppetlabs.com.

Available Actions:

  * **disable** - Disable the Puppet agent
  * **enable** - Enable the Puppet agent
  * **last_run_summary** - Get the summary of the last Puppet run
  * **resource** - Evaluate Puppet RAL resources
  * **runonce** - Invoke a single Puppet run
  * **status** - Get the current status of the Puppet agent

## Usage

You can include this module into your infrastructure as any other module, but as it's designed to work with the [ripienaar mcollective](http://forge.puppet.com/ripienaar/mcollective) module you can configure it via Hiera:

```yaml
mcollective::plugin_classes:
  - mcollective_agent_puppet
```

## Configuration

Server and Client configuration can be added via Hiera and managed through tiers in your site Hiera, they will be merged with any included in this module

```yaml
mcollective_agent_puppet::config:
   example: value
```

This will be added to both the `client.cfg` and `server.cfg`, you can likewise configure server and client specific settings using `mcollective_agent_puppet::client_config` and `mcollective_agent_puppet::server_config`.

These settings will be added to the `/etc/puppetlabs/mcollective/plugin.d/` directory in individual files.

For a full list of possible configuration settings see the module [source repository documentation](http://puppetlabs.com).

## Data Reference

  * `mcollective_agent_puppet::gem_dependencies` - Deep Merged Hash of gem name and version this module depends on
  * `mcollective_agent_puppet::manage_gem_dependencies` - disable managing of gem dependencies
  * `mcollective_agent_puppet::package_dependencies` - Deep Merged Hash of package name and version this module depends on
  * `mcollective_agent_puppet::manage_package_dependencies` - disable managing of packages dependencies
  * `mcollective_agent_puppet::class_dependencies` - Array of classes to include when installing this module
  * `mcollective_agent_puppet::package_dependencies` - disable managing of class dependencies
  * `mcollective_agent_puppet::config` - Deep Merged Hash of common config items for this module
  * `mcollective_agent_puppet::server_config` - Deep Merged Hash of config items specific to managed nodes
  * `mcollective_agent_puppet::client_config` - Deep Merged Hash of config items specific to client nodes
  * `mcollective_agent_puppet::policy_default` - `allow` or `deny`
  * `mcollective_agent_puppet::policies` - List of `actionpolicy` policies to deploy with an agent
  * `mcollective_agent_puppet::client` - installs client files when true - defaults to `$mcollective::client`
  * `mcollective_agent_puppet::server` - installs server files when true - defaults to `$mcollective::server`
  * `mcollective_agent_puppet::ensure` - `present` or `absent`
