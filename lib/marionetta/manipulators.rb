module Marionetta
  module Manipulators
    def [](key)
      all[key.to_s]
    end
    
    require_relative 'manipulators/puppet_manipulator'

    def all()
      {
        :puppet => PuppetManipulator,
      }
    end
  end
end