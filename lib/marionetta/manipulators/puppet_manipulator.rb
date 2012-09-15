require 'celluloid'

module Marionetta
  module Manipulators
    class PuppetManipulator
      include Celluloid

      attr_reader :server
      
      def initialize(server)
        @server = server
      end

      def ssh()
        @ssh ||= SSH.new(server[:hostname])
      end

      def install_deb_repo()
        deb_file = 'puppetlabs-release-stable.deb'
      
        repo_install_cmd = [
          "wget http://apt.puppetlabs.com/#{deb_file}",
          "sudo dpkg -i #{deb_file}", 
          "rm #{deb_file}",
        ].join(' && ')

        repo_check_cmd = "test -f /etc/apt/sources.list.d/puppetlabs.list"

        ssh.run("#{repo_check_cmd} || { #{repo_install_cmd}; }")
      end

      def install_deb()
        install_cmd = [
          'sudo aptitude update',
          'sudo aptitude install -y puppet'
        ].join(' && ')

        ssh.run("which puppet || { #{install_cmd}; }")
      end

      def install()
        install_deb_repo
        install_deb
      end

      def installed?()
        ssh.run('which puppet')
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

        system(cmds.join(' && '))
      end

      def send_archive()
        ssh.rsync('/tmp/puppet.tar.gz', "#{server[:hostname]}:/tmp")
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
        cmds.join(' && ')
        ssh.run(cmds)
      end

      def update()
        install unless installed?
        archive_files
        send_archive
        apply_archive
      end
    end
  end
end