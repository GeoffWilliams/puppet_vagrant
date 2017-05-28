@test "vm instance dir created" {
  test -d /var/lib/vagrantomatic/mycoolvm
}

@test "vagrantfile symlink created" {
  test -h /var/lib/vagrantomatic/mycoolvm/Vagrantfile
}

@test "vagrantfile.json created" {
  test -f /var/lib/vagrantomatic/mycoolvm/Vagrantfile.json
}

@test "VM should be running" {
  cd /var/lib/vagrantomatic/mycoolvm && vagrant status | grep running
}
