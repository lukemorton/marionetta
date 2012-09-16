require 'marionetta'
require 'rake'

module Marionetta
  class RakeHelper
    include ::Rake::DSL if defined?(::Rake::DSL)

    def install_group_tasks(group)
      Manipulators.all.each do |manipulator_name, manipulator_class|
        manipulator_class.tasks.each do |method_name|
          task(task_name(group, manipulator_name, method_name)) do
            group.manipulate_each_server(manipulator_name, method_name)
          end
        end
      end
    end

  private

    def task_name(group, manipulator_name, method_name)
      task_name_parts = [manipulator_name, method_name]

      if group.name
        task_name_parts.unshift(group.name)
      end

      return task_name_parts.join(':')
    end
  end
end