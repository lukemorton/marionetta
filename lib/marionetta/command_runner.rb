# `CommandRunner` is the beast behind Marionetta. It has a
# number of methods for executing commands both locally and
# remotely.
# 
# The external requirement for this file is `open4` so that
# we can easily capture output of commands executed.
# 
require 'open4'

module Marionetta
  class CommandRunner

    ### Server hash requirements

    # The most important requirement is `:logger`. All methods
    # depend upon this property being set since `.system()`
    # (the local command execution method) logs commands,
    # outputs and fatal exceptions using it. It should
    # implement the ruby stdlib `Logger` interface.
    # 
    # Other requirements will be listed with their appropriate
    # methods.
    # 
    def initialize(server)
      @server = server
    end
    
    ### Local execution

    # Local commands are executed with `.system()`. We use
    # `Open4::popen4` to capture the output of the command run
    # neatly.
    # 
    # The command run is logged as info, output as debug and
    # any exceptions thrown are sent as fatal.
    # 
    # You can optionally pass in a block which receives
    # `stdout` and `stderr` as arguments:
    # 
    #     cmd.system('ls ~') do |out, err|
    #       puts out
    #     end
    # 
    def system(*args)
      @last = args.join(' ')
      server[:logger].info(last)

      begin
        status = Open4::popen4(*args) do |pid, stdin, stdout, stderr|
          yield stdout, stderr if block_given?

          [stdout, stderr].each do |io|
            str = io.read
            server[:logger].debug(str) unless str.empty?
          end
        end
      rescue
        server[:logger].fatal(args.join(' '))
        server[:logger].fatal($!)
        exit(1)
      end

      return status.exitstatus == 0
    end

    # Create an archive of a local directory, optionally
    # saving it to a directory or file path.
    # 
    def archive(directory, save_to = nil)
      if save_to.nil?
        save_to = "#{directory}.#{server[:archive][:ext]}"
      elsif File.directory?(save_to)
        dirname = File.basename(directory)
        save_to = "#{save_to}/#{dirname}.#{server[:archive][:ext]}"
      end

      archive_cmd = [
        server[:archive][:command],
        server[:archive][:flags],
        ['-f', save_to],
        ['-C', File.dirname(directory)],
        File.basename(directory),
      ]

      system(*archive_cmd.flatten)
    end

    # The last command run by `.system()` is accessible via
    # the `.last` attribute.
    # 
    attr_reader :last

    ### Remote execution

    # Requirements for remote executions `server[:hostname]`
    # must be set along with `server[:ssh][:command]`.
    # Optionally `server[:ssh][:flags]` can be used to pass in
    # flags such as `-i` for setting SSH keys.
    # 
    # A block can be called against this method just like
    # `.system()` in order to get `stdout` and `stderr`.
    # 
    # An example:
    # 
    #     server = Marionetta.default_server
    #     server[:hostname] = 'example.com'
    #     server[:ssh][:flags] << ['-i', 'keys/private.key']
    #     
    #     cmd = Marionetta::CommandRunner.new(server)
    #     cmd.ssh('ls -l') do |out, err|
    #       puts out
    #     end
    # 
    def ssh(command, &block)
      ssh_cmd = [server[:ssh][:command]]

      if server[:ssh].has_key?(:flags)
        ssh_cmd << server[:ssh][:flags]
      end

      ssh_cmd << server[:hostname]
      ssh_cmd << command

      system(*ssh_cmd.flatten, &block)
    end

    def ssh_extract(archive_path, save_to = File.dirname(archive_path))
      cmds = [
        "mkdir -p #{save_to}",
        "cd #{save_to}",
      ]

      extract_cmd = [
        server[:extract][:command],
        server[:extract][:flags],
        ['-f', archive_path],
      ]

      cmds << extract_cmd.flatten.join(' ')

      ssh(cmds.join(' && '))
    end

    def rsync(from, to)
      rsync_cmd = [server[:rsync][:command]]

      if server[:rsync].has_key?(:flags)
        rsync_cmd << server[:rsync][:flags]
      end
      
      rsync_cmd << [from, to]

      system(*rsync_cmd.flatten)
    end

    def get(file_path, save_to = File.dirname(file_path))
      rsync("#{server[:hostname]}:#{file_path}", save_to)
    end

    def put(file_path, save_to = File.dirname(file_path))
      rsync(file_path, "#{server[:hostname]}:#{save_to}")
    end

  private

    attr_reader :server
  end
end