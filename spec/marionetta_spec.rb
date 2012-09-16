require 'marionetta'
require 'vagrant'

env = Vagrant::Environment.new(:cwd => File.dirname(__FILE__)+'/vagrant')
env.cli('up')

describe Marionetta do
  it 'should provide a default SSH map' do
    Marionetta.default_server
  end
end