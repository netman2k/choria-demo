# mcollective_agent_package version 4.5.0

#### Table of Contents

1. [Overview](#overview)
1. [Usage](#usage)
1. [Configuration](#configuration)

## Overview

Install and uninstall software packages

The mcollective_agent_package module is based on the source from https://github.com/puppetlabs/mcollective-package-agent.

Available Actions:

  * **apt_checkupdates** - Check for APT updates
  * **apt_update** - Update the apt cache
  * **checkupdates** - Check for updates
  * **install** - Install a package
  * **purge** - Purge a package
  * **status** - Get the status of a package
  * **uninstall** - Uninstall a package
  * **update** - Update a package
  * **yum_checkupdates** - Check for YUM updates
  * **yum_clean** - Clean the YUM cache

## Usage

You can include this module into your infrastructure as any other module, but as it's designed to work with the [choria mcollective](http://forge.puppet.com/choria/mcollective) module you can configure it via Hiera:

```yaml
mcollective::plugin_classes:
  - mcollective_agent_package
```

## Configuration

Server and Client configuration can be added via Hiera and managed through tiers in your site Hiera, they will be merged with any included in this module

```yaml
mcollective_agent_package::config:
   example: value
```

This will be added to both the `client.cfg` and `server.cfg`, you can likewise configure server and client specific settings using `mcollective_agent_package::client_config` and `mcollective_agent_package::server_config`.

These settings will be added to the `/etc/puppetlabs/mcollective/plugin.d/` directory in individual files.

For a full list of possible configuration settings see the module [source repository documentation](https://github.com/puppetlabs/mcollective-package-agent).

## Data Reference

  * `mcollective_agent_package::gem_dependencies` - Deep Merged Hash of gem name and version this module depends on
  * `mcollective_agent_package::manage_gem_dependencies` - disable managing of gem dependencies
  * `mcollective_agent_package::package_dependencies` - Deep Merged Hash of package name and version this module depends on
  * `mcollective_agent_package::manage_package_dependencies` - disable managing of packages dependencies
  * `mcollective_agent_package::class_dependencies` - Array of classes to include when installing this module
  * `mcollective_agent_package::package_dependencies` - disable managing of class dependencies
  * `mcollective_agent_package::config` - Deep Merged Hash of common config items for this module
  * `mcollective_agent_package::server_config` - Deep Merged Hash of config items specific to managed nodes
  * `mcollective_agent_package::client_config` - Deep Merged Hash of config items specific to client nodes
  * `mcollective_agent_package::policy_default` - `allow` or `deny`
  * `mcollective_agent_package::policies` - List of `actionpolicy` policies to deploy with an agent
  * `mcollective_agent_package::client` - installs client files when true - defaults to `$mcollective::client`
  * `mcollective_agent_package::server` - installs server files when true - defaults to `$mcollective::server`
  * `mcollective_agent_package::ensure` - `present` or `absent`
