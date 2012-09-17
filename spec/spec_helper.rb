require 'vagrant'
require 'celluloid'

env = Vagrant::Environment.new(:cwd => File.dirname(__FILE__)+'/vagrant')
env.cli('up')

Celluloid.logger.level = Logger::WARN