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

      def can?()
        d = server[:deployer]
        
        if d.has_key?(:from) and d.has_key?(:to)
          return true
        else
          return false
        end
      end

      def deploy()
        release = timestamp
        create_tmp_release_dir(release)
        send_tmp_release_dir_as_archive(release)
        extract_archive_into_release_dir(release)
        symlink_release_dir(release)
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
          symlink_release_dir(rollback_to_release)
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

      def tmp_release_dir(release)
        "/tmp/#{release}"
      end

      def tmp_release_archive(release)
        "/tmp/#{release}.tar.gz"
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

      def create_tmp_release_dir(release)
        tmp_release_dir = tmp_release_dir(release)
        cmd.system("cp -r #{from_dir} #{tmp_release_dir}")

        if server[:deployer].has_key?(:exclude)
          exclude_files = server[:deployer][:exclude]
          exclude_files.map! {|f| "#{tmp_release_dir}/#{f}"}
          cmd.system("rm -rf #{exclude_files.join(' ')}")
        end
      end

      def send_tmp_release_dir_as_archive(release)
        release_archive = tmp_release_archive(release) 
        cmd.archive(tmp_release_dir(release), release_archive)
        cmd.put(release_archive)
      end

      def extract_archive_into_release_dir(release)
        release_archive = tmp_release_archive(release)
        release_dir = release_dir(release)

        unless cmd.ssh_extract(release_archive, release_dir)
          server[:logger].fatal(cmd.last)
          server[:logger].fatal('Could not extract archive')
          exit(1)
        end
      end

      def symlink_release_dir(release)
        release_dir = release_dir(release)

        unless cmd.ssh("rm #{current_dir} && ln -s #{release_dir} #{current_dir}")
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