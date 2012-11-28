# [Marionetta][homepage] is a ruby library for executing
# commands on one or more remote machines via SSH.
# 
# It provides puppet provisioning without the need for a
# puppet master and can also deploy your application code
# (with rollbacks) via rsync. With a RakeHelper you can
# integrate it into your workflow with ease.
# 
# Installing the gem is the best way to start using
# Marionetta. You can do this from command line:
# 
#     gem install marionetta
# 
# Or – better yet – in your Gemfile:
# 
#     source 'http://rubygems.org'
#     gem 'marionetta'
# 
# Marionetta is written by [Luke Morton][author] and licensed
# under the MIT license. The project is [hosted on github][github]
# where you can report issues and send your well thought out
# pull requests.
# 
# [homepage]: http://drpheltright.github.com/marionetta/
# [github]: https://github.com/DrPheltRight/marionetta/
# [author]: http://lukemorton.co.uk
# 
module Marionetta

  VERSION = '0.4.4'

  ### Defining Servers

  # In order to connect to servers you must define configs for
  # each. This method provides a default hash describing some
  # common settings including command binaries, default flags
  # and more.
  # 
  # One interesting this to note is a logger is set, pointing
  # to `STDOUT`.
  # 
  # Do not get too caught up in this method, it is called
  # elsewhere in Marionetta where you can better define your
  # servers. You should consult this method in order to see
  # the defaults.
  # 
  # Any place in this library you see a variable called
  # `server` you can be certain it is a server hash.
  # 
  def self.default_server()
    {
      :logger => Logger.new($stdout),

      :ssh => {
        :command => 'ssh',
        :flags   => [],
      },

      :rsync => {
        :command => 'rsync',
        :flags   => ['-azhP', '--delete'],
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

      :puppet => {},

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
