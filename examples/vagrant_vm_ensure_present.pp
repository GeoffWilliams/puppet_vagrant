#@PDQTest
vagrant_vm { "mycoolvm":
  ensure        => present,
  box           => "centos/7",
  synced_folder => ["/tmp:/tmp"],
  memory        => "1024",
  cpu           => "2",
  provision     => "date",
  user          => "vagrant",
  ip            => "192.168.99.99",
}
