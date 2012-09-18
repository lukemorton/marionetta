require 'spec_helper'
require 'marionetta/command_runner'

def cmd()
  Marionetta::CommandRunner.new(server)
end

describe Marionetta::CommandRunner do
  it 'should get file' do
    cmd.get('/etc/hostname', '/tmp/hosting')
    File.open('/tmp/hosting', 'rb').read.should == "precise64\n"
  end

  it 'should put file' do
    file_path = "#{LIB}/marionetta.rb"
    cmd.put(file_path, '/tmp')
    local = File.open(file_path, 'rb').read

    tmp_path = '/tmp/marionetta.rb'
    cmd.get(tmp_path)
    remote = File.open(tmp_path, 'rb').read
    remote.should == local
  end

  it 'should run commands' do
    cmd.ssh('whoami') do |stdout, stderr|
      stdout.read.should == "vagrant\n"
    end
  end
end