require 'marionetta/group'

describe Marionetta::Group do
  it 'should add server map' do
    vagrant = Marionetta::Group.new

    vagrant.add_server do |s|
      s[:hostname] = 'vagrant@192.168.33.11'
      s[:puppet] = {:manifest => File.dirname(__FILE__)+'/puppet/manifest.pp'}
    end
  end

  it 'should add multiple server maps at once' do
    production = Marionetta::Group.new

    production.add_servers (1..2) do |s, i|
      s[:hostname] = "vagrant@192.168.33.11"
      s[:puppet] = {:manifest => File.dirname(__FILE__)+'/puppet/manifest.pp'}
    end

    production.servers.count.should == 2
  end

  it 'should add sub groups' do
  	staging = Marionetta::Group.new

    staging.add_server do |s|
      s[:hostname] = 'vagrant@192.168.33.11'
      s[:puppet] = {:manifest => File.dirname(__FILE__)+'/puppet/manifest.pp'}
    end

    all = Marionetta::Group.new
    all.add_group(staging)
  end

  it 'should iterate over all servers' do
  end

  it 'should iterate over all servers including those of sub groups' do
  end

  it 'should manipulate each server' do
    # vagrant.manipulate_each_server(:puppet, :update)
  end
end