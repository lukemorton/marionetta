require 'open4'

module Marionetta
  class CommandRunner
    attr_reader :server

    def initialize(server)
      @server = server
    end
    
    def system(*args)
      status = Open4::popen4(*args) do |pid, stdin, stdout, stderr|
        yield stdout, stderr if block_given?

        server[:logger].info(args.join(' '))
        server[:logger].debug(stdout.read)
        server[:logger].debug(stderr.read)
      end
      
      return status.exitstatus == 0
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

    def ssh(command, &block)
      ssh_cmd = [server[:ssh][:command]]

      if server[:ssh].has_key?(:flags)
        ssh_cmd << server[:ssh][:flags]
      end

      ssh_cmd << server[:hostname]
      ssh_cmd << command

      system(*ssh_cmd.flatten, &block)
    end

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
        save_to,
        directory,
      ]

      system(*archive_cmd.flatten)
    end
  end
end