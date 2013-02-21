# `RakeHelper` is provided for those of you who wish to use
# Marionetta in your `Rakefile`.
# 
# One method is provided to expose tasks of a specified group,
# `.install_group_tasks(group)`.
# 
require 'marionetta'
require 'marionetta/manipulators'

module Marionetta
  module RakeHelper
    include ::Rake::DSL if defined?(::Rake::DSL)
    
    extend self

    def install_group_tasks(group)
      install_group_tasks_for(group)

      group.groups.each do |g|
        install_group_tasks_for(g)
      end
    end

    def install_group_task(group, manipulation, task_deps = [])
      groups = [group]

      group.groups.each do |g|
        groups << g
      end

      manipulator, method_name = manipulation

      groups.each do |g|
        class_name = manipulator.name.split('::').last.downcase
        task_desc = task_desc(g, class_name, method_name)
        task_name = task_name(g, class_name, method_name)

        desc(task_desc)
        task(task_name => task_deps) do
          g.manipulate_each_server(manipulator, method_name)
        end
      end
    end

  private

    def install_group_tasks_for(group)
      Manipulators.all.each do |manipulator_name, manipulator_class|
        manipulator_class.tasks.each do |method_name|
          desc(task_desc(group, manipulator_name, method_name))
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

      return "#{manipulator_name}:#{group.name}:#{method_name}"
    end

    def task_desc(group, manipulator_name, method_name)
      "#{method_name} #{manipulator_name} on #{group.name} (marionetta)"
    end
  end
end
