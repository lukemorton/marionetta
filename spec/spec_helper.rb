require 'vagrant'
require 'celluloid'

LIB = File.dirname(__FILE__)+'/../lib'

env = Vagrant::Environment.new(:cwd => File.dirname(__FILE__)+'/vagrant')
env.cli('up')