require 'spec_helper'
require "marionetta/manipulators/debloyer"

describe Marionetta::Manipulators::Debloyer do
  it 'should build a deb' do
    ssh_key_path = File.dirname(__FILE__)+'/vagrant/key'

    server = Marionetta.default_server
    server[:debloyer] = {
      :from => File.dirname(__FILE__)+'/app',
      :fpm => {
        :command => 'fpm',
        :flags => [
          '-n', 'test',
          '-s', 'dir',
          '-t', 'deb',
          '--architecture', 'amd64',
          '--prefix',       '/tmp',
        ],
      },
    }

    Marionetta::Manipulators::Debloyer.new(server).build
  end
end