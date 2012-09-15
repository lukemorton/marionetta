require 'celluloid'

module Marionetta
  class UnitOfWork
    include Celluloid

    def work()
      yield
    end
  end
end