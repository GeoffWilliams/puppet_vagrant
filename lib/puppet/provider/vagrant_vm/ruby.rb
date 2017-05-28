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

Puppet::Type.type(:vagrant_vm).provide(:vagrant_vm, :parent => Puppet::Provider) do
  desc "vagrant_vm support"

  # Only if vagrantomatic libs present
  confine feature: :vagrantomatic

  mk_resource_methods

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  # static accessor - used by `instances` (puppet resource command).  Since this
  # is normally called only once and is in a static context, don't worry about
  # keeping a copy of vom
  def self.vom
    require 'vagrantomatic/vagrantomatic'
    Vagrantomatic::Vagrantomatic.new
  end

  # instance accessor - used by everything else
  def vom
    require 'vagrantomatic/vagrantomatic'
    if ! @vom
      @vom = Vagrantomatic::Vagrantomatic.new
    end
    @vom
  end

  def box=(value)
    @property_flush[:box] = value
  end

  def puppet_master_fqdn=(value)
    @property_flush[:puppet_master_fqdn] = value
  end

  def puppet_master_ip=(value)
    @property_flush[:puppet_master_ip] = value
  end

  def pp_role=(value)
    @property_flush[:pp_role] = value
  end

  def challenge_password=(value)
    @property_flush[:challenge_password] = value
  end

  def certname=(value)
    @property_flush[:certname] = value
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


  def get_vm_instance

    vm_instance = vom.instance(
      @resource[:name],
      config: {
        "box"                => @resource[:box],
        "provision"          => @resource[:provision],
        "synced_folder"      => @resource[:synced_folder],
        "memory"             => @resource[:memory],
        "cpu"                => @resource[:cpu],
        "user"               => @resource[:user],
        "ip"                 => @resource[:ip],
        "puppet_master_fqdn" => @resource[:puppet_master_fqdn],
        "puppet_master_ip"   => @resource[:puppet_master_ip],
        "pp_role"            => @resource[:pp_role],
        "challenge_password" => @resource[:challenge_password],
        "certname"           => @resource[:certname],
      }
    )

    vm_instance.save
    vm_instance
  end

  def present
    get_vm_instance
  end

  def refresh
    vm_instance = vom.instance(@resource[:name])
    vm_instance.reload
  end

  def absent
    vm_instance = vom.instance(@resource[:name])
    vm_instance.purge
  end

  # check if the current ensure is :running (not :present as we *must* indicate
  # to puppet for it to not mark us absent)...
  def vm_running
    # puppet doesn't seem to be able to distinguish between :present and
    # :running (which maps to absent...) so we need to figure out ourselves
    # There's probably a more puppety way of doing this... does anyone know
    # what it is?
    instance = vom.instance(@resource[:name])

    status = false
    if instance.get_vm.vm(:default).state == :running
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
    vom.instances_metadata.collect { |k,v|
      new(:name => k,
        :ensure             => v["ensure"],
        :box                => v["box"],
        :provision          => v["provision"],
        :synced_folder      => v["synced_folder"],
        :memory             => v["memory"],
        :cpu                => v["cpu"],
        :ip                 => v["ip"],
        :puppet_master_fqdn => v["puppet_master_fqdn"],
        :puppet_master_ip   => v["puppet_master_ip"],
        :certname           => v["certname"],
        :pp_role            => v["pp_role"],
        :challenge_password => v["challenge_password"],
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
