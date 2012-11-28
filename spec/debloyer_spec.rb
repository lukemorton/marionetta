require 'spec_helper'
require_relative '../lib/marionetta'
require_relative '../lib/marionetta/manipulators/debloyer'

describe Marionetta::Manipulators::Debloyer do
  it 'should deploy a deb' do
    Marionetta::Manipulators::Debloyer.new(server).deploy
  end
end
