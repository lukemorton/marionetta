require 'celluloid'

module Marionetta
  class Group
    attr_reader :name, :groups

    def initialize(name = nil)
      @name = name
      @groups = []
      @servers = []
    end

    def add_group(group)
      @groups << group
    end

    def add_server()
      server = Marionetta.default_server
      yield server
      @servers << server
    end

    def add_servers(range)
      range.each do |i|
        server = Marionetta.default_server
        yield server, i
        @servers << server
      end
    end

    def servers()
      servers = @servers

      groups.each do |g|
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

      futures.each do |f|
        f.value
      end
    end

    def manipulate_each_server(manipulator_name, method_name)
      each_server do |s|
        manipulator = Manipulators[manipulator_name].new(s)
        manipulator.method(method_name).call()
      end
    end
  end
end