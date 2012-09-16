require 'marionetta'
require 'vagrant'

env = Vagrant::Environment.new(:cwd => File.dirname(__FILE__)+'/vagrant')
env.cli('up')

describe Marionetta do
  it 'can update puppet without a master on multiple nodes asynchronously' do
    def apply_defaults(s)
      s[:username] = 'ubuntu'
      s[:puppet] = {:modules => File.dirname(__FILE__)+'/puppet/modules'}
    end

    staging = Marionetta::Group.new
    staging.add_server do |s|
      s[:hostname] = 'vagrant@192.168.33.11'
      s[:puppet] = {:manifest => File.dirname(__FILE__)+'/puppet/manifest.pp'}
    end

  end
end