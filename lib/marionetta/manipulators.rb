module Marionetta
  module Manipulators
    require_relative 'manipulators/debloyer'
    require_relative 'manipulators/puppet_manipulator'

    def self.all()
      {
        :debloyer => Debloyer,
        :puppet   => PuppetManipulator,
      }
    end

    def self.[](key)
      all[key]
    end
  end
end