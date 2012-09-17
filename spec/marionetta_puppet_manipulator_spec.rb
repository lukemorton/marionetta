require 'spec_helper'
require 'marionetta/manipulators/puppet_manipulator'

describe Marionetta::Manipulators::PuppetManipulator do
  it 'should manipulate one server map' do
    ssh_key_path = File.dirname(__FILE__)+'/vagrant/key'

    server = Marionetta.default_server
    server[:hostname] = 'vagrant@192.168.33.11'
    server[:ssh][:flags] = ['-i', ssh_key_path]
    server[:rsync][:flags] = ['-azP', '-e', "ssh -i #{ssh_key_path}", '--delete']
    server[:puppet] = {
      :manifest => File.dirname(__FILE__)+'/puppet/manifest.pp',
    }

    Marionetta::Manipulators::PuppetManipulator.new(server).update
  end
end