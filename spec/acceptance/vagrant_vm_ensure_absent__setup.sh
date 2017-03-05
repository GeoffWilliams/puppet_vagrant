sh /cut/spec/acceptance/vagrant_vm__setup.sh
mkdir -p /var/lib/vagrant_vms/mycoolvm
touch /var/lib/vagrant_vms/mycoolvm/Vagrantfile
cat > /var/lib/vagrant_vms/mycoolvm/Vagrantfile.json <<END
{ "name": "mycoolvm"}
END
