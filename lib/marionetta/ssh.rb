require 'celluloid'

class Marionetta::SSH
  include Celluloid

  attr_reader :hostname

  def initialize(hostname)
    @hostname = hostname
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
    system("rsync -azP' --delete #{from} #{to}")
  end

  def run(command)
    system("ssh #{hostname} #{command}")
  end
end