require 'spec_helper'
require_relative '../lib/marionetta/manipulators'

describe Marionetta::Manipulators do
  it 'should maintain a list of manipulators' do
    Marionetta::Manipulators.all.count.should > 0
  end
end
