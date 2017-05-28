@test "vm json gone" {
  ! test -f /var/lib/vagrantomatic/mycoolvm/Vagrantfile.json
}

@test "vm vagrantfile gone" {
  ! test -f /var/lib/vagrantomatic/mycoolvm/Vagrantfile
}

@test "vm gone" {
  ! test -d /var/lib/vagrantomatic/mycoolvm
}
