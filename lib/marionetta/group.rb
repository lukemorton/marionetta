module Marionetta
  class Group
    attr_reader :servers

    def initialize()
      @servers = []
    end

    def add_server()
      server = {}
      yield server
      @servers << server
    end

    def add_servers(range)
      range.each do |i|
        server = {}
        yield server, i
        @servers << server
      end
    end

    def each_server()
      servers.each do |s|
        UnitOfWork.new.async.work do
          yield s
        end
      end
    end

    def manipulate_each_server(manipulator_name, method)
      each_server do |s|
        manipulator = Manipulators[manipulator_name].new(s)
        manipulator.method(method).call()
      end
    end
  end
end