#!/bin/bash
rm /var/lib/vagrant_vms -rf
GEM=/opt/puppetlabs/puppet/bin/gem
$GEM list | grep derelict || $GEM install derelict

cp /cut/spec/fixtures/fake_vagrant /usr/bin/vagrant
mkdir -p /opt/puppetlabs/puppet/cache/lib/facter
cp /cut/lib/facter/Vagrantfile /opt/puppetlabs/puppet/cache/lib/facter/Vagrantfile
