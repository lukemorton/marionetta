require 'spec_helper'
require "marionetta"
require "marionetta/manipulators/deployer"

def deployer()
  Marionetta::Manipulators::Deployer.new(server)
end

def cmd()
  Marionetta::CommandRunner.new(server)
end

describe Marionetta::Manipulators::Deployer do
  it 'should deploy' do
    cmd.ssh('rm -rf ~/app')
    deployer.deploy
    cmd.ssh("[ -d ~/app/current ]").should == true
    cmd.ssh("[ -d ~/app/releases ]").should == true
    cmd.ssh("[ -d ~/app/current/app.rb ]").should == true
    cmd.ssh("[ -d ~/app/current/exclude.txt ]").should_not == true
    cmd.ssh("[ -d ~/app/current/exclude/another.txt ]").should_not == true
    cmd.ssh("[ -d ~/app/current/leave-me-out.txt ]").should_not == true
  end

  it 'should list releases' do
    deployer.releases.length.should > 0
  end

  it 'should rollback' do
    deployer.rollback
  end
end