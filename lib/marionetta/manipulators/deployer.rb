require 'marionetta/command_runner'

module Marionetta
  module Manipulators
    class Deployer
      def self.tasks()
        [:deploy, :releases, :rollback]
      end
      
      attr_writer :cmd

      def initialize(server)
        @server = server
      end

      def deploy()
        release = timestamp
        release_archive = "/tmp/#{release}.tar.gz"
        cmd.archive(from_dir, release_archive)
        cmd.put(release_archive)

        release_dir = release_dir(release)

        unless cmd.ssh_extract(release_archive, release_dir)
          server[:logger].fatal(cmd.last)
          server[:logger].fatal('Could not extract archive')
        end

        current_dir = "#{to_dir}/current"
        unless cmd.ssh("ln -s #{release_dir} #{current_dir}")
          server[:logger].fatal(cmd.last)
          server[:logger].fatal('Could not symlink release as current')
        end
      end

      def releases(max = 10)
        releases = []

        cmd.ssh("ls -m #{release_dir}") do |stdout|
          stdout.read.split(', ').each do |release|
            break if releases.length == 10
            releases << release.sub(/[,\s]/, '')
          end
        end

        return releases
      end

      def rollback()
      end

    private
      
      attr_reader :server

      def cmd()
        @cmd ||= CommandRunner.new(server)
      end

      def from_dir()
        server[:debloyer][:from]
      end

      def to_dir()
        server[:debloyer][:to]
      end

      def release_dir(release=nil)
        dir = "#{to_dir}/releases"
        dir << "/#{release}" unless release.nil?
        return dir
      end

      def timestamp()
        Time.new.strftime('%F_%T')
      end
    end
  end
end