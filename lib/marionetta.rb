module Marionetta
  VERSION = '0.3.2'

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