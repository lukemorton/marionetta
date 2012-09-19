require 'spec_helper'
require 'marionetta/group'

describe Marionetta::Group do
  it 'should add server map' do
    vagrant = Marionetta::Group.new
    vagrant.add_server({:hostname => 'localhost'})
    vagrant.servers.count.should == 1
  end

  it 'should add server map from block' do
    vagrant = Marionetta::Group.new

    vagrant.add_server do |s|
      s[:hostname] = 'vagrant@192.168.33.11'
      s[:puppet] = {:manifest => File.dirname(__FILE__)+'/puppet/manifest.pp'}
    end

    vagrant.servers.count.should == 1
  end

  it 'should extend provided map when block also given' do
    vagrant = Marionetta::Group.new
    
    vagrant.add_server(:hostname => 'localhost') do |s|
      s[:additional] = true
    end

    vagrant.servers.first.has_key?(:hostname).should == true
    vagrant.servers.first.has_key?(:additional).should == true
  end

  it 'should add sub groups' do
    staging = Marionetta::Group.new

    staging.add_server do |s|
      s[:hostname] = 'vagrant@192.168.33.11'
      s[:puppet] = {:manifest => File.dirname(__FILE__)+'/puppet/manifest.pp'}
    end

    all = Marionetta::Group.new
    all.add_group(staging)

    all.servers.count.should == 1
  end

  it 'should iterate over all servers' do
    staging = Marionetta::Group.new

    staging.add_server do |s|
      s[:hostname] = 'vagrant@192.168.33.11'
      s[:puppet] = {:manifest => File.dirname(__FILE__)+'/puppet/manifest.pp'}
    end
    
    count = 0

    staging.each_server do |s|
      count += 1
    end

    count.should == 1
  end

  it 'should iterate over all servers including those of sub groups' do
    staging = Marionetta::Group.new

    staging.add_server do |s|
      s[:hostname] = 'vagrant@192.168.33.11'
      s[:puppet] = {:manifest => File.dirname(__FILE__)+'/puppet/manifest.pp'}
    end

    all = Marionetta::Group.new
    all.add_group(staging)

    count = 0

    all.each_server do |s|
      count += 1
    end

    count.should == 1
  end

  it 'should manipulate each server' do
    vagrant = Marionetta::Group.new
    vagrant.add_server(server)
    vagrant.manipulate_each_server(:deployer, :releases) do |server, releases|
      releases.length.should > 0
    end
  end
end