require 'spec_helper'
describe 'puppet_vagrant::install' do
  context 'compiles' do
    it { should compile }
  end

  context 'with default values for all parameters' do
    it { should contain_class('puppet_vagrant::install') }
  end
end
