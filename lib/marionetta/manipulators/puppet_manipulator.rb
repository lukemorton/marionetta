require 'marionetta/command_runner'

module Marionetta
  module Manipulators
    class PuppetManipulator
      def self.tasks()
        [:install, :update]
      end

      attr_writer :cmd
      
      def initialize(server)
        @server = server
      end

      def can?()
        server[:puppet].has_key?(:manifest)
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
        puppet_tmp = '/tmp/puppet'

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
        cmd.put('/tmp/puppet.tar.gz')
      end

      def apply_archive()
        cmd.ssh_extract('/tmp/puppet.tar.gz')
        cmds = ['cd /tmp/puppet']

        puppet_cmd = ['sudo puppet apply']

        if server[:puppet].has_key?(:modules)
          puppet_cmd << '--modulepath=/tmp/puppet/modules'
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