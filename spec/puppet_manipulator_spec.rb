require 'spec_helper'
require_relative '../lib/marionetta/manipulators/puppet_manipulator'

describe Marionetta::Manipulators::PuppetManipulator do
  it 'should manipulate one server map' do
    Marionetta::Manipulators::Puppet.new(server).update
  end
end
