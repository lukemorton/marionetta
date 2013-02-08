require 'spec_helper'
require 'rake'
require_relative '../lib/marionetta/group'
require_relative '../lib/marionetta/rake_helper'

describe Marionetta::RakeHelper do
  it 'should install rake tasks' do
    vagrant = Marionetta::Group.new(:vagrant)
    vagrant.add_server(server)

    # Marionetta::RakeHelper.install_group_tasks(vagrant)
    Rake::Task.define_task(:help) do; p 'ey'; end

    Marionetta::RakeHelper.install_group_task(
      vagrant,
      [Marionetta::Manipulators::Deployer, :deploy],
      [:help])

    Marionetta::RakeHelper.install_group_task(
      vagrant,
      [Marionetta::Manipulators::Puppet, :update])

    Rake::Task.tasks.count.should > 0

    Rake::Task['puppet:vagrant:update'].invoke
    Rake::Task['deployer:vagrant:deploy'].invoke
    # Rake::Task['deployer:vagrant:rollback'].invoke
  end
end
