sh /cut/spec/acceptance/vagrant_vm__setup.sh
mkdir -p $VM_DIR/mycoolvm
touch $VM_DIR/mycoolvm/Vagrantfile
cat > $VM_DIR/mycoolvm/Vagrantfile.json <<END
{ "name": "mycoolvm"}
END
