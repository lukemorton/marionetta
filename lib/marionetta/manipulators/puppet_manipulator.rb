# `PuppetManipulator` copies a puppet manifest and optionally
# modules to a remote machine and applies them.
# 
# You could do this with a puppet master instance, and that
# could (and most likely is) the right option for you. However
# if you do not want to host an additional node as your puppet
# master or want to push changes from your machine directly to
# nodes them this class maybe what you're looking for.
# 
require 'marionetta/command_runner'

module Marionetta
  module Manipulators
    class Puppet
      include Commandable

      ### RakeHelper tasks

      # `PupperManipulator` provides two rake tasks when used
      # with `RakeHelper` namely `:install` and `:update`. 
      # When applied through `RakeHelper` they will appear
      # namespaced under `:puppet` and your group name.
      #
      # With a group name of `:staging` would appear as:
      # 
      #     puppet:staging:install
      #     puppet:staging:update
      # 
      def self.tasks()
        [:install, :update]
      end

      ### Server hash requirements

      # The key `[:puppet][:manifest]` must be set in your
      # `server` hash in order for `PuppetManipulator` to
      # function correctly.
      # 
      def initialize(server)
        @server = server
      end

      # Call `.can?()` to check if the `:manifest` key has
      # been set in the `server[:puppet]`.
      # 
      def can?()
        server[:puppet].has_key?(:manifest)
      end

      ### Installing puppet

      # `PuppetManipulator` provides the `.install()` method
      # to install puppet on debian or ubuntu servers.
      # 
      def install()
        install_deb_repo
        install_deb
      end

      ### Updating puppet

      # Use `.update()` to package up your manifest and
      # optionally modules and send them to your remote
      # machine. Once there they will be applied.
      # 
      # If puppet is not installed, we attempt to install it
      # before applying the manifest.
      # 
      def update()
        install unless installed?
        archive_files
        send_archive
        apply_archive
      end

    private

      def installed?()
        cmd.ssh('which puppet')
      end

      def install_deb_repo()
        deb_file = 'puppetlabs-release-stable.deb'
      
        repo_install_cmd = [
          "wget http://apt.puppetlabs.com/#{deb_file}",
          "sudo dpkg -i #{deb_file}", 
          "rm #{deb_file}",
        ].join(' && ')

        repo_check_cmd = "test -f /etc/apt/sources.list.d/puppetlabs.list"

        cmd.ssh("#{repo_check_cmd} || { #{repo_install_cmd}; }")
      end

      def install_deb()
        install_cmd = [
          'sudo aptitude update',
          'sudo aptitude install -y puppet'
        ].join(' && ')

        cmd.ssh("which puppet || { #{install_cmd}; }")
      end

      def puppet_tmp()
        "/tmp/puppet_#{server[:hostname]}"
      end

      def archive_files()
        cmds = [
          "rm -rf #{puppet_tmp}",
          "mkdir #{puppet_tmp}",
          "cp #{server[:puppet][:manifest]} #{puppet_tmp}/manifest.pp",
        ]

        if server[:puppet].has_key?(:modules)
          cmds << "cp -r #{server[:puppet][:modules]} #{puppet_tmp}/modules"
        end

        cmd.system(cmds.join(' && '))
        cmd.archive(puppet_tmp)
      end

      def send_archive()
        cmd.put("#{puppet_tmp}.tar.gz")
      end

      def apply_archive()
        cmd.ssh_extract("#{puppet_tmp}.tar.gz")
        cmds = ["cd #{puppet_tmp}"]

        puppet_cmd = ['sudo puppet apply']

        if server[:puppet].has_key?(:modules)
          puppet_cmd << "--modulepath=#{puppet_tmp}/modules"
        end

        puppet_cmd << 'manifest.pp'

        if server[:puppet].has_key?(:flags)
          puppet_cmd << server[:puppet][:flags]
        end

        cmds << puppet_cmd.flatten.join(' ')
        
        cmd.ssh(cmds.join(' && '))
      end
    end
  end
end
