module Marionetta
  class CommandRunner
    attr_reader :server

    def initialize(server)
      @server = server
    end
    
    def system(*args)
      server[:logger].info(args.join(' '))
      return Kernel.system(*args)
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

    def ssh_extract(archive_path, save_to = File.dirname(archive_path))
      cmds = [
        "mkdir -p #{save_to}",
        "cd #{save_to}",
      ]

      extract_cmd = [
        server[:extract][:command],
        server[:extract][:flags],
        archive_path,
      ]

      cmds << extract_cmd.flatten.join(' ')

      ssh(cmds.join(' && '))
    end
  end
end