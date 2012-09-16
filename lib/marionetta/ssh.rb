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
      system("rsync", "-azP", "--delete", from, to)
    end

    def run(command)
      system("ssh", server[:hostname], command)
    end
  end
end