@test "vm json gone" {
  ! test -f /var/lib/vagrant_vms/mycoolvm/Vagrantfile.json
}

@test "vm vagrantfile gone" {
  ! test -f /var/lib/vagrant_vms/mycoolvm/Vagrantfile
}

@test "vm gone" {
  ! test -d /var/lib/vagrant_vms/mycoolvm
}
