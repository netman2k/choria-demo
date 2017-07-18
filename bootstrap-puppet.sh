#!/bin/bash
rpm -Uvh https://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm
yum -y install @development
yum -y install puppet-agent
/opt/puppetlabs/bin/puppet agent --test --waitforcert 10 --onetime
