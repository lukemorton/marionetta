module Marionetta
  VERSION     = '0.3.2'
  DESCRIPTION = 'For lightweight puppet mastery. Organise
                 multiple machines via rsync and SSH rather
                 than using puppet master'

  def self.default_server()
    {
      :logger => Logger.new($stdout),

      :ssh => {
        :command => 'ssh',
        :flags   => [],
      },

      :rsync => {
        :command => 'rsync',
        :flags   => ['-azP', '--delete'],
      },

      :archive => {
        :command => 'tar',
        :flags => ['-zvc'],
        :ext => 'tar.gz',
      },

      :extract => {
        :command => 'tar',
        :flags => ['-xv'],
      },

      :deployer => {},

      :debloyer => {
        :name => 'debloyer',
        :fpm => {
          :command => 'fpm',
          :flags => [
            '-s', 'dir',
            '-t', 'deb',
          ],
        },
      },
    }
  end
end