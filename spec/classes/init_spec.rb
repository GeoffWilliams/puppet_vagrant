require 'spec_helper'
describe 'puppet_vagrant' do
  context 'with default values for all parameters' do
    it { should contain_class('puppet_vagrant') }
  end
end
