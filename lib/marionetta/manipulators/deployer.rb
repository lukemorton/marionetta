# `Deployer` is a class for rsyncing your application to a
# remote machine.
# 
# Using a directory structure similar to capistrano `Deployer`
# maintains a folder of releases so you may rollback quickly.
# 
require 'marionetta'
require 'marionetta/commandable'
require 'marionetta/directory_sync'

module Marionetta
  module Manipulators
    class Deployer
      include Commandable

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

      # Setup deploy environment on remote server.
      # 
      def setup()
        create_directories
      end

      # Run a deploy to your remote server. The process
      # involves:
      # 
      #  - `:from` directory rsync'd to remote cache directory
      #    with `:exclude` files being ignored
      #  - cache directory copied on remote machine to
      #    releases directory
      #  - `:before_script` and `:before_scripts` run
      #  - release directory symlinked to a current directory
      #  - `:after_script` and `:before_scripts` run
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

        DirectorySync.sync(server, from_dir, cache_dir, server[:deployer])
        copy_cache_dir_to_release(release)

        symlink_shared_directories(release)

        send_scripts()
        run_script(:before, release)
        symlink_release_dir(release)
        run_script(:after, release)
      end

      # Get an array of all releases including those which
      # have been rolled back (skipped).
      # 
      def releases_including_skipped()
        files = []

        cmd.ssh("ls -m #{releases_dir}") do |stdout|
          files.concat(stdout.read.split(/[,\s]+/))
        end

        return files
      end

      # Get an array of all releases call `.releases()`. Any
      # release that is subsequently rolled back will not
      # be listed.
      # 
      def releases()
        releases_including_skipped.delete_if {|r| r =~ /^skip-/}
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

      # Delete release directories on remote machine.
      # 
      def clean()
        rels = releases()
        rels.pop()
        rm = ['rm', '-r'].concat(rels.map {|r| release_dir(r)})
        rm << release_dir('skip-*')
        cmd.ssh(rm)
      end

    private

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

      def shared_dir()
        "#{to_dir}/shared"
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

      def install_dir_cmd(dir)
        owner = 'www-data'
        group = 'www-data'
        chmod = '775'

        return "install -d #{dir} -o #{owner} -g #{group} -m #{chmod}"
      end

      def create_directories()
        install = [install_dir_cmd(releases_dir), install_dir_cmd(cache_dir)]
        
        if server[:deployer].has_key?(:shared_directories)
          install << install_dir_cmd(shared_dir)
        end

        cmd.ssh(install)
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

      def copy_cache_dir_to_release(release)
        release_dir = release_dir(release)
        cmd.ssh("mkdir -p #{releases_dir} && cp -r #{cache_dir} #{release_dir}")
      end

      def symlink_shared_directories(release)
        return unless server[:deployer].has_key?(:shared_directories)

        release_dir = release_dir(release)
        cmds = []

        server[:deployer][:shared_directories].each do |d|
          to = "#{release_dir}/#{d}"
          from = "#{shared_dir}/#{d}"

          cmds << "rm -r #{to}"
          cmds << "mkdir -p #{from}"
          cmds << "ln -s #{from} #{to}"
        end

        cmd.ssh(cmds.join(' && '))
      end

      def send_scripts()
        files = []

        [:before, :after].each do |script|
          singular_script_key = "#{script}_script".to_sym
          plural_script_key = "#{script}_scripts".to_sym

          if server[:deployer].has_key?(singular_script_key)
            files << server[:deployer][singular_script_key]
          end

          if server[:deployer].has_key?(plural_script_key)
            files.concat(server[:deployer][plural_script_key])
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
          server[:logger].fatal(cmd.last)
          server[:logger].fatal('Could not symlink release as current')
          exit(1)
        end
      end

      def timestamp()
        Time.new.strftime('%F_%H-%M-%S')
      end
    end
  end
end
