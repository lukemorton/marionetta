require 'spec_helper'
require "marionetta"
require "marionetta/manipulators/debloyer"

describe Marionetta::Manipulators::Debloyer do
  it 'should deploy a deb' do
    ssh_key_path = File.dirname(__FILE__)+'/vagrant/key'

    s = Marionetta.default_server

    s[:hostname] = 'vagrant@192.168.33.11'
    ssh_key_path = File.dirname(__FILE__)+'/vagrant/key'
    s[:ssh][:flags] = ['-i', ssh_key_path]
    s[:rsync][:flags] = ['-azP', '-e', "ssh -i #{ssh_key_path}", '--delete']

    s[:debloyer][:from] = File.dirname(__FILE__)+'/app'
    s[:debloyer][:to] = '/home/vagrant'
    s[:debloyer][:name] = 'test'

    Marionetta::Manipulators::Debloyer.new(s).deploy
  end
end