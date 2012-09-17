require 'spec_helper'
require 'marionetta/rake_helper'

describe Marionetta::RakeHelper do
  it 'should install rake tasks' do
    vagrant = Marionetta::Group.new(:vagrant)

    vagrant.add_server do |s|
      s[:hostname] = 'vagrant@192.168.33.11'
      ssh_key_path = File.dirname(__FILE__)+'/vagrant/key'
      s[:ssh][:flags] = ['-i', ssh_key_path]
      s[:rsync][:flags] = ['-azP', '-e', "ssh -i #{ssh_key_path}", '--delete']
      s[:puppet] = {:manifest => File.dirname(__FILE__)+'/puppet/manifest.pp'}
    end

    Marionetta::RakeHelper.new(vagrant).install_group_tasks
    Rake::Task.tasks.count.should > 0

    Rake::Task['vagrant:puppet:update'].invoke
  end
end