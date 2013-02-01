# `Deployer` is a class for rsyncing your application to a
# remote machine.
# 
# Using a directory structure similar to capistrano `Deployer`
# maintains a folder of releases so you may rollback quickly.
# 
require 'marionetta'
require 'marionetta/command_runner'

module Marionetta
  module Manipulators
    class Deployer

      ### RakeHelper tasks

      # `Deployer` provides two rake tasks when used with
      # `RakeHelper` namely `:deploy` and `:rollback`. When
      # applied through `RakeHelper` they will appear
      # namespaced under `:deployer` and your group name.
      # 
      # With a group name of `:staging` would appear as:
      # 
      #     deployer:staging:deploy
      #     deployer:staging:rollback
      # 
      def self.tasks()
        [:deploy, :rollback]
      end

      ### Server hash requirements

      # The keys `[:deployer][:from]` and `[:deployer][:to]`
      # must be set in your `server` hash in order for
      # `Deployer` to work.
      # 
      def initialize(server)
        @server = server
      end

      # Call `.can?()` to check if the correct keys have be
      # passed in as the server.
      # 
      def can?()
        d = server[:deployer]
        
        if d.has_key?(:from) and d.has_key?(:to)
          return true
        else
          return false
        end
      end

      ### Deploying

      # Call `.deploy()` to run a deploy to your remote
      # server. The process involves:
      # 
      #  - `:from` directory rsync'd to remote cache directory
      #    with `:exclude` files being ignored
      #  - cache directory copied on remote machine to
      #    releases directory
      #  - `:before_script` run
      #  - release directory symlinked to a current directory
      #  - `:after_script` run
      # 
      # The directory structure under `server[:deployer][:to]`
      # looks something like this:
      # 
      #     cache/
      #     current/ -> ./releases/2012-09-20_14:04:39
      #     releases/
      #       2012-09-20_13:59:15
      #       2012-09-20_14:04:39
      # 
      def deploy()
        release = create_release_name()

        create_cache_dir()
        sync_cache_dir()
        copy_cache_dir_to_release(release)

        send_scripts()
        run_script(:before, release)
        symlink_release_dir(release)
        run_script(:after, release)
      end

      # To get an array of all releases call `.releases()`.
      # Any release that is subsequently rolled back will not
      # be listed.
      # 
      def releases()
        releases = []

        cmd.ssh("ls -m #{releases_dir}") do |stdout|
          stdout.read.split(/[,\s]+/).each do |release|
            releases << release unless release.index('skip-') == 0
          end
        end

        return releases
      end

      # If you push out and need to rollback to the previous
      # version you can use `.rollback()` to do just that.
      # Currently you can only rollback once at a time.
      # 
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
      
      ### Dependency Injection

      # To use your own alternative to `CommandRunner` you can
      # set an object of your choice via the `.cmd=` method.
      # 
      attr_writer :cmd

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

      def tmp_dir()
        if server[:deployer].has_key?(:tmp)
          server[:deployer][:tmp]
        else
          Marionetta.default_server[:deployer][:tmp]
        end
      end

      def cache_dir()
        "#{to_dir}/cache"
      end

      def releases_dir()
        "#{to_dir}/releases"
      end
      
      def release_dir(release)
        "#{releases_dir}/#{release}"
      end

      def current_dir()
        "#{to_dir}/current"
      end

      def fatal(message)
        server[:logger].fatal(cmd.last)
        server[:logger].fatal(message)
        exit(1)
      end

      def create_release_name()
        name = timestamp

        if server[:deployer].has_key?(:version)
          version_cmd = server[:deployer][:version][:command]

          cmd.system("cd #{from_dir} && #{version_cmd}") do |stdout|
            version = stdout.read.strip
            name << "_#{version}" unless version.empty?
          end
        end

        return name
      end

      def rsync_exclude_flags(exclude_files)
        exclude_files = exclude_files.clone
        exclude_files.map! {|f| Dir["#{from_dir}/#{f}"]}
        exclude_files.flatten!
        exclude_files.map! {|f| f.sub(from_dir+'/', '')}
        exclude_files.map! {|f| ['--exclude', f]}
        exclude_files.flatten!
        return exclude_files
      end

      def create_cache_dir()
        cmd.ssh("test -d #{cache_dir} || mkdir -p #{cache_dir}")
      end

      def sync_cache_dir()
        args = [Dir[from_dir+'/*'], cache_dir]

        if server[:deployer].has_key?(:exclude)
          args.concat(rsync_exclude_flags(server[:deployer][:exclude]))
        end

        unless cmd.put(*args)
          fatal('Could not rsync cache dir')
        end
      end

      def copy_cache_dir_to_release(release)
        release_dir = release_dir(release)
        cmd.ssh("mkdir -p #{releases_dir} && cp -r #{cache_dir} #{release_dir}")
      end

      def send_scripts()
        files = []

        [:before, :after].each do |script|
          script_key = "#{script}_script".to_sym

          if server[:deployer].has_key?(script_key)
            files << server[:deployer][script_key]
          end
        end

        unless files.empty?
          cmd.put(files, tmp_dir)
        end
      end

      def run_script(script, release)
        script_key = "#{script}_script".to_sym

        if server[:deployer].has_key?(script_key)
          script = server[:deployer][script_key]
          tmp_script = "#{tmp_dir}/#{File.basename(script)}"
          cmd.ssh("chmod +x #{tmp_script} && exec #{tmp_script} #{release}")
        end
      end

      def symlink_release_dir(release)
        release_dir = release_dir(release)

        unless cmd.ssh("rm -f #{current_dir} && ln -s #{release_dir} #{current_dir}")
          fatal('Could not symlink release as current')
        end
      end

      def timestamp()
        Time.new.strftime('%F_%T')
      end
    end
  end
end
