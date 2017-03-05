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
require 'puppet_x/puppet_vagrant'
Puppet::Type.type(:vagrant_vm).provide(:vagrant_vm, :parent => Puppet::Provider) do
  desc "vagrant_vm support"

  # Only if vagrant installed
  confine :exists => '/usr/bin/vagrant'

  mk_resource_methods

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def box=(value)
    @property_flush[:box] = value
  end

  def synced_folder=(value)
    @property_flush[:synced_folder] = value
  end

  def memory=(value)
    @property_flush[:memory] = value
  end

  def cpu=(value)
    @property_flush[:cpu] = value
  end

  def provision=(value)
    @property_flush[:provision] = value
  end

  def ip=(value)
    @property_flush[:ip] = value
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  # def exists?
  #   vm_instance = PuppetX::PuppetVagrant::Instance.new(
  #     @resource[:name],
  #     @resource[:box],
  #     @resource[:provision],
  #     @resource[:synced_folder],
  #     @resource[:memory],
  #     @resource[:cpu],
  #     @resource[:user],
  #     @resource[:ip],
  #     false,
  #   )
  #   vm_instance.configured?
  # end

  def get_vm_instance
    vm_instance = PuppetX::PuppetVagrant::Instance.new(
      @resource[:name],
      @resource[:box],
      @resource[:provision],
      @resource[:synced_folder],
      @resource[:memory],
      @resource[:cpu],
      @resource[:user],
      @resource[:ip],
    )
  end

  def present
    get_vm_instance
  end

  def refresh
    vm_instance = PuppetX::PuppetVagrant::Instance.new(@resource[:name])
    vm_instance.reload
  end

  def absent
    vm_instance = PuppetX::PuppetVagrant::Instance.new(@resource[:name])
    vm_instance.purge
  end

  # check if the current ensure is :running (not :present as we *must* indicate
  # to puppet for it to not mark us absent)...
  def vm_running
    # puppet doesn't seem to be able to distinguish between :present and
    # :running (which maps to absent...) so we need to figure out ourselves
    # There's probably a more puppety way of doing this... does anyone know
    # what it is?
    i = PuppetX::PuppetVagrant::Instance.new(
      @resource[:name],
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
    )

    status = false
    if i.get_vm.vm(:default).state == :running
      status = true
    end

    status
  end

  def running
    present.start
  end

  def stopped
    present.stop
  end

  # puppet resource command (get) support
  def self.instances
    PuppetX::PuppetVagrant::Instance.instances.collect { |k,v|
      puts k
      puts v


puts "ensure #{v['ensure']}"
        new(:name => k,
          :ensure        => v["ensure"],
          :box           => v["box"],
          :provision     => v["provision"],
          :synced_folder => v["synced_folder"],
          :memory        => v["memory"],
          :cpu           => v["cpu"],
          :ip            => v["ip"]
        )

    }

  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def flush
    if ! @property_flush.empty?
      # gettin instance updates the .json file
      vm = get_vm_instance
      if @resource[:ensure] == :running
        # if we're supposed to be running then reload for settings to take effect
        vm.reload
      end
    end
  end

end
