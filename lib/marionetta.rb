module Marionetta
  VERSION     = '0.1.0'
  DESCRIPTION = 'For lightweight puppet mastery. Organise
                 multiple machines via rsync and SSH rather
                 than using puppet master'

  require_relative 'marionetta/ssh'
  require_relative 'marionetta/manipulators'
  require_relative 'marionetta/unit_of_work'
  require_relative 'marionetta/group'
end