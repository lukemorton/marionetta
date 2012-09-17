require 'spec_helper'
require 'marionetta'

describe Marionetta do
  it 'should provide a default SSH map' do
    Marionetta.default_server
  end
end