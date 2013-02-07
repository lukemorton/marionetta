module Marionetta
  module Commandable
    ### Dependency Injection

    # To use your own alternative to `CommandRunner` you can
    # set an object of your choice via the `.cmd=` method.
    # 
    attr_writer :cmd

  private

    attr_reader :server

    def cmd()
      @cmd ||= CommandRunner.new(server)
    end
  end
end
