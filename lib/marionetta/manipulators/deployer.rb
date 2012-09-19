require 'marionetta/command_runner'

module Marionetta
  module Manipulators
    class Deployer
      def self.tasks()
        [:deploy, :rollback]
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
          exit(1)
        end

        symlink_release(release)
      end

      def releases()
        releases = []

        cmd.ssh("ls -m #{release_dir}") do |stdout|
          stdout.read.split(/[,\s]+/).each do |release|
            releases << release unless release.index('skip-') == 0
          end
        end

        return releases
      end

      def rollback()
        rollback_to_release = releases[-2]

        if rollback_to_release.nil?
          server[:logger].warn('No release to rollback to')
        else
          current_release_dir = release_dir(releases.last)
          skip_current_release_dir = release_dir("skip-#{releases.last}")
          cmd.ssh("mv #{current_release_dir} #{skip_current_release_dir}")
          symlink_release(rollback_to_release)
        end
      end

    private
      
      attr_reader :server

      def cmd()
        @cmd ||= CommandRunner.new(server)
      end

      def from_dir()
        server[:deployer][:from]
      end

      def to_dir()
        server[:deployer][:to]
      end

      def release_dir(release=nil)
        dir = "#{to_dir}/releases"
        dir << "/#{release}" unless release.nil?
        return dir
      end

      def current_dir()
        "#{to_dir}/current"
      end

      def symlink_release(release)
        release_dir = release_dir(release)

        unless cmd.ssh("rm -rf #{current_dir} && ln -s #{release_dir} #{current_dir}")
          server[:logger].fatal(cmd.last)
          server[:logger].fatal('Could not symlink release as current')
          exit(1)
        end
      end

      def timestamp()
        Time.new.strftime('%F_%T')
      end
    end
  end
end