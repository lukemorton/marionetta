require 'spec_helper'
require "marionetta"
require "marionetta/manipulators/deployer"

def deployer()
  Marionetta::Manipulators::Deployer.new(server)
end

describe Marionetta::Manipulators::Deployer do
  it 'should deploy a deb' do
    deployer.deploy
  end

  it 'should list releases' do
    deployer.releases.length.should > 0
  end
end