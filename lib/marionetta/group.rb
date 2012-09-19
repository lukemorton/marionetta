require 'marionetta'
require 'marionetta/manipulators'
require 'celluloid'

module Marionetta
  class Group
    attr_reader :name

    def initialize(name = nil)
      @name = name
      @groups = []
      @servers = []
    end

    def add_group(group)
      @groups << group
    end

    def groups()
      groups = @groups

      groups.each do |g|
        groups.concat(g.groups)
      end

      return groups
    end

    def add_server(server = nil)
      server ||= Marionetta.default_server
      yield server if block_given?
      @servers << server
    end

    def servers()
      servers = @servers

      @groups.each do |g|
        servers.concat(g.servers)
      end

      return servers
    end

    def each_server()
      futures = []

      servers.each do |s|
        server = s.clone.freeze

        futures << Celluloid::Future.new do
          yield server
        end
      end

      return_values = []

      futures.each do |f|
        return_values << f.value
      end

      return return_values
    end

    def manipulate_each_server(manipulator_name, method_name)
      each_server do |s|
        manipulator = Manipulators[manipulator_name].new(s)

        if manipulator.can?
          return_val = manipulator.method(method_name).call()
          yield s, return_val if block_given?
        else
          s[:logger].warn(
            "Could not Manipulators[:#{:manipulator}].#{method_name}()")
        end
      end
    end
  end
end