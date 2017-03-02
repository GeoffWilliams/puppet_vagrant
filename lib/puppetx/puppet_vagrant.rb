# Copyright 2017 Geoff Williams for Declarative Systems PTY LTD
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
require "derelict"
require 'json'

module PuppetX
  module PuppetVagrant
    VAGRANT_DIR     = "/usr/local/lib/vagrant"
    VAGRANT_VM_DIR  = "/var/lib/vagrant_vms"

    class Instance
      def initialize(
          name,
          box           = false,
          provision     = false,
          synced_folder = false,
          memory        = false,
          cpu           = false,
          user          = false)

        @user   = user
        @config = {
          :name           => name,
          :box            => box,
          :provision      => provision,
          :synced_folder  => synced_folder,
          :memory         => memory,
          :cpu            => cpu,
        }

        ensure_config
        ensure_vagrantfile
      end

      # Vagrant to be driven from a .json config file, allt
      # the parameters are externalised here
      def ensure_config
        File.open(configfile,"w") do |f|
          f.write(@config.to_json)
        end
      end

      # The Vagrantfile itself is shipped as part of this
      # module and delivered via pluginsync, so we just need
      # to symlink it for each directory.  This gives us the
      # benefit being to update by dropping a new module too
      def ensure_vagrantfile
        target_file = File.join(Puppet[:factpath].split(':')[0], 'Vagrantfile')
        ln_sf(src, vagrantfile, :force)
      end

      def delete_vagrantfile
        FileUtils.rm_r(vm_instance_dir)
      end

      def vm_instance_dir
        Path.join(VAGRANT_VM_DIR, @config['name'])
      end

      def vagrantfile
        Path.join(vm_instance_dir, "Vagrantfile")
      end

      def configfile
        Path.join(vm_instance_dir, "Vagrantfile.json")
      end

      def get_vm
        # Create an instance (represents a Vagrant installation)
        instance = Derelict.instance(VAGRANT_DIR)
        vm = instance.connect(vm_instance_dir)

        vm
      end


      def start
        get_vm.start!
      end

      def stop
        get_vm.stop!
      end

      def purge
        get_vm.destroy!
        delete_vagrantfile
      end
    end
  end
end
