require 'spec_helper'
require_relative '../lib/marionetta'
require_relative '../lib/marionetta/manipulators/deployer'

def deployer()
  Marionetta::Manipulators::Deployer.new(server)
end

def cmd()
  Marionetta::CommandRunner.new(server)
end

describe Marionetta::Manipulators::Deployer do
  it 'should setup' do
    cmd.ssh('rm -rf ~/app')
    deployer.setup
    cmd.ssh("[ -d ~/app/releases ]").should == true
    cmd.ssh("[ -d ~/app/shared ]").should == true
    cmd.ssh("[ -d ~/app/cache ]").should == true
  end
  
  it 'should deploy' do
    deployer.deploy
    deployer.deploy
    cmd.ssh("[ -L ~/app/current ]").should == true
    cmd.ssh("[ -f ~/app/current/app.rb ]").should == true
    cmd.ssh("[ -f ~/app/current/app-copy.rb ]").should == true
    cmd.ssh("[ -f ~/app/current/exclude.txt ]").should_not == true
    cmd.ssh("[ -f ~/app/current/exclude/another.txt ]").should_not == true
    cmd.ssh("[ -f ~/app/current/after ]").should_not == true
    cmd.ssh("[ -f ~/app/current/after2 ]").should_not == true
    cmd.ssh("[ -L ~/app/current/logs ]").should == true
  end

  it 'should list releases' do
    deployer.releases.length.should > 0
  end

  it 'should rollback' do
    deployer.rollback
  end

  it 'should clean up' do
    deployer.clean
    deployer.releases_including_skipped.length.should == 1
  end
end
