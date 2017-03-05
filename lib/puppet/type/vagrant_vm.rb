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

require 'puppet/parameter/boolean'

Puppet::Type.newtype(:vagrant_vm) do
  @doc = "vagrant_vm a file"

  ensurable do
    desc "Create or remove the vagrant_vm"

     newvalue(:present) do
       provider.present
     end

     newvalue(:absent) do
       provider.absent
     end

     newvalue(:running) do
       provider.running
     end

    newvalue(:stopped) do
      provider.stopped
    end

    defaultto(:present)

    def insync?(is)
      is.to_s == should.to_s or
        (is.to_s == 'running' and should.to_s == 'present') or
        (is.to_s == 'stopped' and should.to_s == 'present') or
        (is.to_s == 'present' and should.to_s == 'running' and provider.vm_running)
    end
  end

  # newparam(:vagrant_dir) do
  #   desc "The vagrant box image to use"
  #   defaultto "/vagrantvms"
  # end

  newproperty(:box) do
    desc "The vagrant box image to use"
    defaultto 'centos/7'
    newvalue(/^\S+$/)
  end

  newparam(:synced_folder) do
    desc "Array of synced folders to use"
    #defaultto(["#{vagrant_dir}/#{title}:/vagrant"])
  end

  newproperty(:memory) do
    desc "Memory to allocate to this VM in MB"
    defaultto "512"
  end

  newproperty(:cpu) do
    desc "vCPUs to allocate to this VM"
    defaultto "1"
  end

  newproperty(:provision) do
    desc "Provision script to run after booting VM"
    defaultto "1"
  end

  newparam(:name, :namevar => :true) do
    desc "Name of this VM instance"
  end

  newparam(:user) do
    desc "User to run VM as"
    defaultto "vagrant"
  end

  newproperty(:ip) do
    desc "IP address"
  end

  def refresh
    if @resource[:ensure] == :running
      provider.refresh
    end
  end
end
