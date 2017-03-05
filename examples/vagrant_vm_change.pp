# Example of changing properties of an existing vm (assuming you already created)
vagrant_vm { "mycoolvm":
  ensure        => running,
  box           => "centos/7",
  synced_folder => ["/tmp:/tmp"],
  memory        => "6000",
  cpu           => "4",
  provision     => "yum install -y bash",
  user          => "vagrant",
  ip            => "192.168.99.99",
}
