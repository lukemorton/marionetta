module Marionetta
  class SSH
    attr_reader :server

    def initialize(server)
      @server = server
    end

    def get(local_dir, file)
      rsync("#{server[:hostname]}", local_dir)
    end

    def put(remote_path, base_name = File.basename(remote_path))
      require 'tempfile'
      Tempfile.open(base_name) do |fp|
        fp.puts yield
        fp.flush
        rsync(fp.path, "#{server[:hostname]}:#{remote_path}")
      end
    end

    def rsync(from, to)
      rsync_cmd = [server[:rsync][:command]]

      if server[:rsync].has_key?(:flags)
        rsync_cmd << server[:rsync][:flags]
      end
      
      rsync_cmd << [from, to]

      system(*rsync_cmd.flatten)
    end

    def run(command)
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