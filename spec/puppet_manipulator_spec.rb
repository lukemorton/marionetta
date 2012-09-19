require 'spec_helper'
require 'marionetta/manipulators/puppet_manipulator'

describe Marionetta::Manipulators::PuppetManipulator do
  it 'should manipulate one server map' do
    Marionetta::Manipulators::PuppetManipulator.new(server).update
  end
end