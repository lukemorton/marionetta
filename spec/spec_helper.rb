require 'vagrant'
require 'celluloid'

LIB = File.dirname(__FILE__)+'/../lib'

env = Vagrant::Environment.new(:cwd => File.dirname(__FILE__)+'/vagrant')
env.cli('up')

def server()
    s = Marionetta.default_server

    s[:hostname] = 'vagrant@192.168.33.11'
    ssh_key_path = File.dirname(__FILE__)+'/vagrant/key'
    s[:ssh][:flags] = ['-i', ssh_key_path]
    s[:rsync][:flags] = ['-azP', '-e', "ssh -i #{ssh_key_path}", '--delete']

    s[:debloyer][:from] = File.dirname(__FILE__)+'/app'
    s[:debloyer][:to] = '/home/vagrant'
    s[:debloyer][:name] = 'test'

    s[:puppet] = {
      :manifest => File.dirname(__FILE__)+'/puppet/manifest.pp',
    }

    return s
end