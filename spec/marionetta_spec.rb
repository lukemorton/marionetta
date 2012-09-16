# $:.unshift(File.dirname(__FILE__))

require 'marionetta'
require 'vagrant'

describe Marionetta do
  it 'can update puppet without a master on multiple nodes asynchronously' do
    def apply_defaults(s)
      s[:username] = 'ubuntu'
      s[:puppet] = {:modules => File.dirname(__FILE__)+'/puppet/modules'}
    end

    staging = Marionetta::Group.new
    staging.add_server do |s|
      apply_defaults(s)

      s[:hostname] = 'staging.example.com'
      s[:puppet][:manifest] = File.dirname(__FILE__)+'/puppet/manifests/staging.pp'
    end
    
    production = Marionetta::Group.new
    production.add_servers (1..2) do |s, i|
      apply_defaults(s)

      s[:hostname] = "prod-#{i}.example.com"
      s[:puppet][:manifest] = File.dirname(__FILE__)+'/puppet/manifests/production-web.pp'
    end

    # all = Marionetta::Group.new(staging, production)
    # all.manipulate_each_server(:puppet, :update)

    # Boot up vagrant for testing
    env = Vagrant::Environment.new(:cwd => File.dirname(__FILE__)+'/vagrant')
    env.cli('up')

    # Manipulate a group of servers
    vagrant = Marionetta::Group.new
    vagrant.add_server do |s|
      apply_defaults(s)

      s[:hostname] = 'vagrant@192.168.33.11'
      s[:puppet] = {:manifest => File.dirname(__FILE__)+'/puppet/manifest.pp'}
    end
    vagrant.manipulate_each_server(:puppet, :update)
  end
end