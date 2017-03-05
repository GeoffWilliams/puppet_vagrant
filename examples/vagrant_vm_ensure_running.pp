#@PDQTest
vagrant_vm { "mycoolvm":
  ensure        => running,
  box           => "puppetlabs/centos-7.2-64-nocm",
  synced_folder => ["/tmp:/tmp"],
  memory        => "1024",
  cpu           => "2",
  provision     => "date",
  user          => "vagrant",
  ip            => "192.168.99.99",
}
