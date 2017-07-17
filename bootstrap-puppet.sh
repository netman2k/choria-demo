#!/bin/bash
rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum -y install @development
yum -y install puppet-agent
/opt/puppetlabs/bin/puppet agent --test --waitforcert 10 --onetime
