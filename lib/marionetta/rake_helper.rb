require 'marionetta'
require 'marionetta/manipulators'
require 'rake'

module Marionetta
  class RakeHelper
    include ::Rake::DSL if defined?(::Rake::DSL)

    attr_reader :group

    def initialize(group)
      @group = group
    end

    def install_group_tasks()
      install_group_tasks_for(group)

      group.groups.each do |g|
        install_group_tasks_for(g)
      end
    end

  private

    def install_group_tasks_for(group)
      Manipulators.all.each do |manipulator_name, manipulator_class|
        manipulator_class.tasks.each do |method_name|
          desc("#{method_name} #{manipulator_name} on #{group.name} (marionetta)")
          task(task_name(group, manipulator_name, method_name)) do
            group.manipulate_each_server(manipulator_name, method_name)
          end
        end
      end
    end

    def task_name(group, manipulator_name, method_name)
      unless group.name
        raise 'Group must be named'
      end

      return "#{group.name}:#{manipulator_name}:#{method_name}"
    end
  end
end