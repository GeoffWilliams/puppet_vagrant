# Puppet_vagrant::Install
#
# Install Vagrant and also the gems we need for managing
# vagrant files into this node
class puppet_vagrant::install(
    $user     = "vagrant",
    $group    = "vagrant",
    $package  = "https://releases.hashicorp.com/vagrant/1.9.5/vagrant_1.9.5_x86_64.rpm",
) {
  user { $user:
    ensure => present,
  }

  group { $group:
    ensure => present,
  }

  # Gem to control vagrant, used by the type and provider
  package { "vagrantomatic":
    ensure   => '0.3.3',
    provider => "puppet_gem",
  }

  # Vagrant - has to be installed this way until https://tickets.puppetlabs.com/browse/PUP-3323
  # is resolved
  package { "vagrant":
    ensure   => present,
    provider => "rpm",
    source   => $package,
  }

  # Vagrant fails to up on some boxes without rsync
  ensure_packages("rsync", {"ensure"=>"present"})
}
