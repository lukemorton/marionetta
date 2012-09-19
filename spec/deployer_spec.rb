require 'spec_helper'
require "marionetta"
require "marionetta/manipulators/deployer"

def deployer()
  Marionetta::Manipulators::Deployer.new(server)
end

describe Marionetta::Manipulators::Deployer do
  it 'should deploy' do
    deployer.deploy
  end

  it 'should list releases' do
    deployer.releases.length.should > 0
  end

  it 'should rollback' do
    deployer.rollback
  end
end