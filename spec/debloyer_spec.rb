require 'spec_helper'
require "marionetta"
require "marionetta/manipulators/debloyer"

describe Marionetta::Manipulators::Debloyer do
  it 'should deploy a deb' do
    Marionetta::Manipulators::Debloyer.new(server).deploy
  end
end