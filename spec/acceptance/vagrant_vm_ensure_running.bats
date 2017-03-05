@test "vm instance dir created" {
  test -d /var/lib/vagrant_vms/mycoolvm
}

@test "vagrantfile symlink created" {
  test -h /var/lib/vagrant_vms/mycoolvm/Vagrantfile
}

@test "vagrantfile.json created" {
  test -f /var/lib/vagrant_vms/mycoolvm/Vagrantfile.json
}

@test "VM should be running" {
  cd /var/lib/vagrant_vms/mycoolvm && vagrant status
}
