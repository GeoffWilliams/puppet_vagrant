#!/bin/bash
export VM_DIR="/var/lib/vagrantomatic"

rm $VM_DIR -rf
GEM=/opt/puppetlabs/puppet/bin/gem
$GEM list | grep vagrantomatic || $GEM install vagrantomatic

cp /cut/spec/fixtures/fake_vagrant /usr/bin/vagrant
mkdir -p /opt/puppetlabs/puppet/cache/lib/facter
cp /cut/lib/facter/Vagrantfile /opt/puppetlabs/puppet/cache/lib/facter/Vagrantfile
