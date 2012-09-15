module Marionetta
  module Manipulators
    require_relative 'manipulators/puppet_manipulator'

    def all()
      {
        :puppet => PuppetManipulator,
      }
    end
    
    def [](key)
      all[key.to_s]
    end
  end
end