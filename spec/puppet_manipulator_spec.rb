require 'spec_helper'
require_relative '../lib/marionetta/manipulators/puppet'

describe Marionetta::Manipulators::Puppet do
  it 'should manipulate one server map' do
    Marionetta::Manipulators::Puppet.new(server).update
  end
end
