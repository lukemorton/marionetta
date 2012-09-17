module Marionetta
  VERSION     = '0.1.10'
  DESCRIPTION = 'For lightweight puppet mastery. Organise
                 multiple machines via rsync and SSH rather
                 than using puppet master'

  def self.default_server()
    {
      :ssh => {
        :command => 'ssh',
        :flags   => [],
      },
      :rsync => {
        :command => 'rsync',
        :flags   => ["-azP", "--delete"],
      },
    }
  end
end