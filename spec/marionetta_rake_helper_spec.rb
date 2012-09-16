require 'marionetta'
require 'marionetta/rake_helper'

describe Marionetta::RakeHelper do
  it 'should install rake tasks' do
    group = Marionetta::Group.new(:staging)
    Marionetta::RakeHelper.new.install_group_tasks(group)
  end
end