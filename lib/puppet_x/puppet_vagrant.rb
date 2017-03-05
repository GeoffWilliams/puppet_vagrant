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
    VAGRANT_DIR       = "/usr"
    VAGRANT_VM_DIR    = "/var/lib/vagrant_vms"
    VAGRANTFILE       = "Vagrantfile"
    VAGRANTFILE_JSON  = "#{VAGRANTFILE}.json"

    class Instance
      def self.parse_instance(instance_name)
        instance_dir = File.join(VAGRANT_VM_DIR, instance_name)
        config_file = File.join(instance_dir, VAGRANTFILE_JSON)
        if File.exists?(config_file)
          json = File.read(config_file)
          config = JSON.parse(json)

          # This does work and queries the current status using derelic however
          # puppet only interprets :present or :absent so its a waste.  Also
          # anything != :present becomes :absent, so :running == :absent. I give
          # up...
          #
          # i = PuppetX::PuppetVagrant::Instance.new(
          #   instance_name,
          #   false,
          #   false,
          #   false,
          #   false,
          #   false,
          #   false,
          #   false,
          #   false,
          # )
          #
          # config["ensure"] = i.get_vm.vm(:default).state
          config["ensure"] = :present
        else
          # VM missing or damaged
          config = {}
          config["ensure"] = :absent
          config["name"]   = instance_name
        end


        config
      end

      def self.instances
        instance_wildcard = File.join(VAGRANT_VM_DIR, "*", VAGRANTFILE)
        instances = {}
        Dir.glob(instance_wildcard).each { |f|
          elements = f.split(File::SEPARATOR)
          # /var/lib/vagrant_vms/mycoolvm/vagrantfile
          # ---------------------^^^^^^^^------------
          name = elements[elements.size - 2]

          instances[name] = parse_instance(name)
        }

        instances
      end

      def configured?
        configured = false
        if Dir.exists? (vm_instance_dir) and File.exists?(configfile) and File.exists?(vagrantfile)

          json = File.read(configfile)
          have_config = JSON.parse(json)

          if have_config == @config
            configured = true
          end
        end
        configured
      end

      def initialize(
          name,
          box           = false,
          provision     = false,
          synced_folder = false,
          memory        = false,
          cpu           = false,
          user          = false,
          ip            = false,
          act           = true)

        @user   = user
        @config = {
          "name"           => name,
          "box"            => box,
          "provision"      => provision,
          "synced_folder"  => synced_folder,
          "memory"         => memory,
          "cpu"            => cpu,
          "ip"             => ip,
        }


        if act
          if ! Dir.exists?(vm_instance_dir)
            FileUtils.mkdir_p(vm_instance_dir)
          end

          ensure_config
          ensure_vagrantfile
        end
      end        

      # Vagrant to be driven from a .json config file, all
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
        source_file = File.join(Puppet[:factpath].split(':')[0], 'Vagrantfile')
        FileUtils.ln_sf(source_file, vagrantfile)
      end

      def delete_vagrantfile
        FileUtils.rm_r(vm_instance_dir)
      end

      def vm_instance_dir
        File.join(PuppetX::PuppetVagrant::VAGRANT_VM_DIR, @config["name"])
      end

      def vagrantfile
        File.join(vm_instance_dir, VAGRANTFILE)
      end

      def configfile
        File.join(vm_instance_dir, VAGRANTFILE_JSON)
      end

      def get_vm
        # Create an instance (represents a Vagrant installation)
        instance = Derelict.instance(PuppetX::PuppetVagrant::VAGRANT_DIR)
        result = instance.execute('--version') # Derelict::Executer object
        print "success" if result.success?
        vm = instance.connect(vm_instance_dir)

        vm
      end


      def start
        Puppet.notice "Starting Vagrant_vm[#{@config['name']}]"
        result = get_vm.execute(:up)
        result.success?
        puts "*************up! #{result.success?}"
      end

      def stop
        Puppet.notice "Stopping Vagrant_vm[#{@config['name']}]"
        get_vm.execute(:suspend)
      end

      def purge
        Puppet.notice "purging Vagrant_vm[#{@config['name']}]"
        get_vm.execute(:destroy)
        delete_vagrantfile
      end

      def reload
        Puppet.notice "Reloading Vagrant_vm[#{@config['name']}]"
        get_vm.execute(:reload)
      end
    end
  end
end
