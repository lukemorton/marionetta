require 'spec_helper'
require 'marionetta/rake_helper'

describe Marionetta::RakeHelper do
  it 'should install rake tasks' do
    vagrant = Marionetta::Group.new(:vagrant)
    vagrant.add_server(server)

    Marionetta::RakeHelper.new(vagrant).install_group_tasks
    Rake::Task.tasks.count.should > 0

    Rake::Task['vagrant:puppet:update'].invoke
    Rake::Task['vagrant:debloyer:deploy'].invoke
  end
end