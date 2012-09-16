require 'marionetta/group'

describe Marionetta::Group do
  it 'should add server map' do
    vagrant = Marionetta::Group.new

    vagrant.add_server do |s|
      s[:hostname] = 'vagrant@192.168.33.11'
      s[:puppet] = {:manifest => File.dirname(__FILE__)+'/puppet/manifest.pp'}
    end
    
    vagrant.manipulate_each_server(:puppet, :update)
  end

  it 'should add multiple server maps at once' do
    production = Marionetta::Group.new

    production.add_servers (1..2) do |s, i|
      s[:hostname] = "prod-#{i}.example.com"
      s[:puppet] = {:manifest => File.dirname(__FILE__)+'/puppet/manifest.pp'}
    end

    puts production.servers
  end

  it 'should add sub groups' do
  	staging = Marionetta::Group.new

    staging.add_server do |s|
      s[:hostname] = 'vagrant@192.168.33.11'
      s[:puppet] = {:manifest => File.dirname(__FILE__)+'/puppet/manifest.pp'}
    end

    all = Marionetta::Group.new

    all.add_group(staging)
    all.add_group(production)
  end

  it 'should iterate over all servers' do
  	
  end

  it 'should iterate over all servers including those of sub groups' do
  end
end