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

Puppet::Type.type(:vagrant_vm).provide(:vagrant_vm) do
  desc "vagrant_vm support"

  def exists?
    File.file?(@resource[:name])
  end

  def present
    vm_instance = PuppetX::PuppetVagrant::Instance.new(
      @resource[:name],
      @resource[:box],
      @resource[:synced_folder],
      @resource[:memory],
      @resource[:cpu],
      @resource[:provision],
      @resource[:user],
    )
  end

  def absent
    vm_instance = PuppetX::PuppetVagrant::Instance.new(@resource[:name])
    vm_instance.purge
  end

  def running
    present.start
  end

  def stopped
    present.stop
  end

end
