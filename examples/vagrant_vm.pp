vagrant_vm { "mycoolvm":
  ensure        => running,
  box           => "centos7",
  synced_folder => ["/tmp:/tmp"],
  memory        => "1024",
  cpu           => "2",
  provision     => "date",
  user          => "vagrant",
}
