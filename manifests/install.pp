# Puppet_vagrant::Install
#
# Install Vagrant and also the gems we need for managing
# vagrant files into this node 
class puppet_vagrant::install(
    $user     = "vagrant",
    $group    = "vagrant",
    $package  = "https://releases.hashicorp.com/vagrant/1.9.2/vagrant_1.9.2_x86_64.rpm",
) {
  user { $user:
    ensure => present,
  }

  group { $group:
    ensure => present,
  }

  puppet_gem { "derelict":
    ensure => present,
  }

  package { "vagrant":
    ensure => present,
    source => $package,
  }

  # Installation of Vagrant now requires installer, gems don't work
  # any more (good)
  https://releases.hashicorp.com/vagrant/1.9.2/vagrant_1.9.2_x86_64.rpm?_ga=1.127977547.632083575.1475994455
}
