require 'spec_helper'
require 'marionetta/rake_helper'

describe Marionetta::RakeHelper do
  it 'should install rake tasks' do
    group = Marionetta::Group.new(:staging)
    Marionetta::RakeHelper.new(group).install_group_tasks
    Rake::Task.tasks.count.should > 0
  end
end