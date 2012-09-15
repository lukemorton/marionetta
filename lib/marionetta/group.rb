class Marionetta::Group
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
      yield s
    end
  end
end