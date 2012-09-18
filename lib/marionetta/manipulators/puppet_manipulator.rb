require 'marionetta'
require 'marionetta/command_runner'

module Marionetta
  module Manipulators
    class PuppetManipulator
      attr_writer :cmd

      def self.tasks()
        [:install, :update]
      end
      
      def initialize(server)
        @server = server
      end

      def install()
        install_deb_repo
        install_deb
      end

      def installed?()
        cmd.ssh('which puppet')
      end

      def update()
        install unless installed?
        archive_files
        send_archive
        apply_archive
      end

    private
    
      attr_reader :server

      def cmd()
        @cmd ||= CommandRunner.new(server)
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

      def archive_files()
        cmds = [
          'rm -rf /tmp/puppet',
          'mkdir /tmp/puppet',
          "cp #{server[:puppet][:manifest]} /tmp/puppet/manifest.pp",
        ]

        if server[:puppet].has_key?(:modules)
          cmds << "cp -r #{server[:puppet][:modules]} /tmp/puppet/modules"
        end

        cmds << 'cd /tmp'
        cmds << 'tar cvfz puppet.tar.gz puppet'

        cmd.system(cmds.join(' && '))
      end

      def send_archive()
        cmd.put('/tmp/puppet.tar.gz')
      end

      def apply_archive()
        cmds = [
          'cd /tmp',
          'tar xvfz puppet.tar.gz',
          'cd puppet',
        ]

        puppet_cmd = 'sudo puppet apply '

        if server[:puppet].has_key?(:modules)
          puppet_cmd += '--modulepath=/tmp/puppet/modules '
        end

        puppet_cmd += 'manifest.pp'

        if server[:puppet].has_key?(:options)
          puppet_cmd += " #{server[:puppet][:options]}"
        end

        cmds << puppet_cmd
        
        cmd.ssh(cmds.join(' && '))
      end
    end
  end
end