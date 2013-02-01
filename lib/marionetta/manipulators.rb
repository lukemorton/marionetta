# `Manipulators` is a container for registering manipulators.
# 
# The interface of a manipulator is:
# 
#     self.tasks()        an array of methods to expose via
#                         RakeHelpers *optional*
# 
#     initialize(server)  *required*
#     can?()              *required*
#     
module Marionetta
  module Manipulators

    # We automatically require the manipulators packaged with
    # this library. *Is this a good idea?*
    # 
    require_relative 'manipulators/deployer'
    require_relative 'manipulators/debloyer'
    require_relative 'manipulators/puppet_manipulator'

    # A hash of all the manipulators.
    # 
    def self.all()
      {
        :deployer => Deployer,
        :debloyer => Debloyer,
        :puppet   => Puppet,
      }
    end

    # Get a manipulator.
    # 
    def self.[](key)
      all[key]
    end
  end
end
