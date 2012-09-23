# `Group` represents a collection of `server` hashes and
# provides `.each_server()` and `.manipulate_each_server` as
# isolated interation methods.
# 
# You can also nest groups within other groups so that
# multiple groups can be operated on at once.
# 
# The external requirement for this file is `celluloid` so we
# can iterate over `@servers` in parallel.
# 
require 'marionetta'
require 'marionetta/manipulators'
require 'celluloid'

module Marionetta
  class Group

    # Group name is currently optional.
    # 
    def initialize(name = nil)
      @name = name
      @groups = []
      @servers = []
    end

    # The name of the group.
    # 
    attr_reader :name

    # Nest a group using `.add_group()`.
    # 
    def add_group(group)
      @groups << group
    end

    # Get all descending groups contained within this group.
    # 
    def groups()
      groups = @groups

      groups.each do |g|
        groups.concat(g.groups)
      end

      return groups
    end

    # Add a `server` hash or build on the default server in a
    # block.
    # 
    # Example:
    # 
    #     staging = Marionetta::Group.new(:staging)
    #     staging.add_server(:hostname => 'ubuntu@example.com')
    #     staging.add_server do |s|
    #       s[:hostname] = 'ubuntu@example.com'
    #     end
    # 
    def add_server(server = nil)
      server ||= Marionetta.default_server
      yield server if block_given?
      @servers << server
    end

    # Get servers in this group and all descendant groups.
    # 
    def servers()
      servers = @servers

      @groups.each do |g|
        servers.concat(g.servers)
      end

      return servers
    end

    # Iterate over each `server` definition (including nested
    # servers) in parallel by passing a block.
    # 
    #     each_server do |s|
    #       cmd = Marionetta::CommandRunner.new(s)
    #       cmd.ssh('whoami') do |out|
    #         puts out.read
    #       end
    #     end
    # 
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

    # Manipulate each server by passing a manipulator key as
    # registered with `Manipulators` and a method name.
    # 
    # If manipulator cannot be run on a server definition then
    # a warn message will be logged.
    # 
    # If block passed in then the server and return value for
    # each server will be passed in when complete.
    # 
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