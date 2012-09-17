require 'marionetta'
require 'marionetta/group'

describe Marionetta::Group do
  it 'should add server map' do
    vagrant = Marionetta::Group.new

    vagrant.add_server do |s|
      s[:hostname] = 'vagrant@192.168.33.11'
      s[:puppet] = {:manifest => File.dirname(__FILE__)+'/puppet/manifest.pp'}
    end

    vagrant.servers.count.should == 1
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

    vagrant.add_server do |s|
      s[:hostname] = 'vagrant@192.168.33.11'
      ssh_key_path = File.dirname(__FILE__)+'/vagrant/key'
      s[:ssh][:flags] = ['-i', ssh_key_path]
      s[:rsync][:flags] = ['-azP', '-e', "ssh -i #{ssh_key_path}", '--delete']
      s[:puppet] = {:manifest => File.dirname(__FILE__)+'/puppet/manifest.pp'}
    end

    vagrant.manipulate_each_server(:puppet, :update)
  end
end