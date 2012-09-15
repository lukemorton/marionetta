require 'celluloid'

module Marionetta::Manipulators::Puppet
  class PuppetManipulator
    include Celluloid

    attr_reader :server
    
    def initialize(server)
      @server = server
    end

    def ssh()
      @ssh or= SSH.new(server[:hostname])
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

    def install_puppet()
      install_cmd = [
        'sudo apt-get update',
        'sudo aptitude install -y puppet'
      ].join(' && ')

      ssh.run("which puppet || { #{install_cmd}; }")
    end

    def install()
      install_puppet_deb_repo
      install_puppet
    end

    def installed?()
      ssh.run('which puppet')
    end

    def archive_files()
      cmds = [
        'rm -rf /tmp/puppet',
        'mkdir /tmp/puppet',
        "cp #{server[:puppet][:manifest]} /tmp/puppet/manifest.pp"
      ]

      if defined? server[:puppet][:modules]
        cmds += ["cp -r #{server[:puppet][:modules]} /tmp/puppet/modules"]
      end

      cmds += [
        'cd /tmp',
        'tar cvfz puppet.tar.gz puppet'
      ]

      cmds.join(' && ')

      system(cmds)
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

      if defined? server[:puppet][:modules]
        puppet_cmd += '--modulepath=/tmp/puppet/modules '
      end

      puppet_cmd += 'manifest.pp'

      if defined? server[:puppet][:options]
        puppet_cmd += " #{puppet_options}"
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

  def update(*groups)
    groups.each do |group|
      group.each_server do |s|    
        PuppetManipulator.new(s).update
      end
    end
  end
end