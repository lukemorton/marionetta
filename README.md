# Marionetta

Marionetta is a ruby library for executing commands to one
or more remote machines via SSH.

It provides puppet provisioning without the need for a puppet
master and can also deploy your application code (with
rollbacks) via rsync. With a RakeHelper you can integrate it
into your workflow with ease.

Installing the gem is the best way to start using Marionetta.
You can do this from command line:

```
gem install marionetta
```

Or – better yet – in your Gemfile:

``` ruby
source 'http://rubygems.org'
gem 'marionetta'
```

## Defining a group of servers

Marionetta allows you to describe and manipulate a number of
servers in parallel via SSH. First you need to define a group
of servers:

``` ruby
require 'marionetta/group'

servers = Marionetta::Group.new

servers.add_server do |s|
  s[:hostname] = 'ubuntu@example.com'
end

servers.add_server do |s|
  s[:hostname] = 'another@host.com'
  s[:ssh][:flags] << ['-i', 'keys/private.key']
end
```

## Looping over a group

Continuing on from our example of defining a group of servers
above, we will now iterate over the servers:

``` ruby
# Each block executes in it's own asynchronous thread
servers.each_server do |s|
  cmd = Marionetta::CommandRunner.new(s)

  # Send a command via SSH
  cmd.ssh('whoami') do |out, err|
    puts out.read
  end

  # Get a file
  cmd.get('/var/backups/database')

  # Put a file
  cmd.put('/etc/motd')
end
```

## Playing puppet master

Instead of running a puppet master server you can use
Marionetta to orchestrate a number instances.

``` ruby
require 'marionetta/group'

servers = Marionetta::Group.new

servers.add_server do |s|
  s[:hostname] = 'ubuntu@example.com'
  s[:puppet][:manifest] = 'puppet/manifest.pp'
  s[:puppet][:modules] = 'puppet/modules'
end

# Install and update puppet on each server according to
# each servers puppet settings
servers.manipulate_each_server(:puppet, :update)
```

## Using the deployer

Also included is a deployment mechanism similar to capistrano.
You can use this to deploy releases of folders from a local
machine to a remote one over SSH.

``` ruby
require 'marionetta/group'

staging = Marionetta::Group.new(:staging)

staging.add_server do |s|
  s[:hostname] = 'staging.example.com'
  s[:deployer][:from] = '/my-app'
  s[:deployer][:to] = '/home/staging/www'
end

staging.manipulate_each_server(:deployer, :deploy)
```

The deployer also supports listing releases:

``` ruby
staging.manipulate_each_server(:deployer, :releases) do |server, releases|
  puts server[:hostname], releases
end
```

Oh and you can rollback to the last release too!

``` ruby
staging.manipulate_each_server(:deployer, :rollback)
```

## Using Marionetta in your Rakefile

Marionetta provides an easy mechanism to generate rake tasks
for each of your groups.

In your Rakefile you can do something like so:

``` ruby
require 'marionetta/group'
require 'marionetta/rake_helper'

staging = Marionetta::Group.new(:staging)

staging.add_server do |s|
  s[:hostname] = 'staging.example.com'
  s[:puppet][:manifest] = 'puppet/manifest.pp'
  s[:deployer][:from] = '/my-app'
  s[:deployer][:to] = '/home/staging/www'
end

Marionetta::RakeHelper.new(staging).install_group_tasks
```

The tasks `puppet:staging:install`, `puppet:staging:update`,
`deployer:staging:deploy` and `deployer:staging:rollback`
will now be available in your Rakefile.

**Groups must have names if you want to generate rake tasks.**

## Author

Luke Morton a.k.a. DrPheltRight

## License

MIT