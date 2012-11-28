require 'vagrant'
require 'celluloid'
require_relative '../lib/marionetta'

LIB = File.dirname(__FILE__)+'/../lib'

env = Vagrant::Environment.new(:cwd => File.dirname(__FILE__)+'/vagrant')
env.cli('up')

def server()
  s = Marionetta.default_server

  # s[:logger].level = Logger::INFO

  s[:hostname] = 'vagrant@192.168.33.11'

  ssh_key_path = File.dirname(__FILE__)+'/vagrant/key'
  s[:ssh][:flags] = ['-i', ssh_key_path]
  s[:rsync][:flags] = ['-azP', '-e', "ssh -i #{ssh_key_path}", '--delete']

  app_dir = File.dirname(__FILE__)+'/app'

  s[:deployer][:from] = app_dir
  s[:deployer][:to] = '~/app'
  s[:deployer][:exclude] = ['exclud*', 'before', 'after']
  s[:deployer][:after_script] = "#{app_dir}/after"

  s[:debloyer][:from] = app_dir
  s[:debloyer][:to] = '~/app-deb'
  s[:debloyer][:name] = 'test'

  s[:puppet] = {
    :manifest => File.dirname(__FILE__)+'/puppet/manifest.pp',
  }

  return s
end
