#package { "VirtualBox-5.1":
#  ensure   => present,
#  source   => "http://download.virtualbox.org/virtualbox/5.1.14/VirtualBox-5.1-5.1.14_112924_el7-1.x86_64.rpm",
#}

exec { "install virtualbox":
  unless  => "rpm -q VirtualBox-5.1",
  command => "yum install -y http://download.virtualbox.org/virtualbox/5.1.14/VirtualBox-5.1-5.1.14_112924_el7-1.x86_64.rpm",
  path    => ['/usr/bin','/bin','/usr/sbin','/sbin'],
}

include puppet_vagrant::install
