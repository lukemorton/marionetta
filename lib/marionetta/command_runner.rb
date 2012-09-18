require 'open4'

module Marionetta
  class CommandRunner
    attr_reader :server

    def initialize(server)
      @server = server
    end
    
    def system(*args)
      status = Open4::popen4(*args) do |pid, stdin, stdout, stderr|
        server[:logger].info(args.join(' '))
        server[:logger].debug(stdout.read)
        server[:logger].debug(stderr.read)
      end
      
      return status.exitstatus
    end

    def rsync(from, to)
      rsync_cmd = [server[:rsync][:command]]

      if server[:rsync].has_key?(:flags)
        rsync_cmd << server[:rsync][:flags]
      end
      
      rsync_cmd << [from, to]

      system(*rsync_cmd.flatten)
    end

    def get(file_path, local_dir = File.basename(file_path))
      rsync("#{server[:hostname]}:#{file_path}", local_dir)
    end

    def put(file_path, remote_dir = File.basename(file_path))
      rsync(file_path, "#{server[:hostname]}:#{remote_dir}")
    end

    def ssh(command)
      ssh_cmd = [server[:ssh][:command]]

      if server[:ssh].has_key?(:flags)
        ssh_cmd << server[:ssh][:flags]
      end

      ssh_cmd << server[:hostname]
      ssh_cmd << command

      system(*ssh_cmd.flatten)
    end
  end
end