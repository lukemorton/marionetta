# Marionetta

A small ruby library for executing remote commands on a number
of servers. Comes with puppet mastery built in.

```
gem install marionetta
```

## Defining a group of servers

Marionetta allows you to describe and manipulate a number of
servers in parallel via SSH. First you need to define a group
of servers:

``` ruby
require 'marionetta'

servers = Marionetta::Group.new

servers.add_server do |s|
  s[:hostname] = 'ubuntu@example.com'
end

servers.add_server do |s|
  s[:hostname] = 'another@host.com'
  s[:ssh][:flags] = ['-i', 'keys/private.key']
end
```

## Looping over a group

Continuing on from our example of defining a group of servers
above, we will now iterate over the servers:

``` ruby
servers.each_server do |s|
  # Run command on each server in parallel
  Marionetta::CommandRunner.new(s).ssh('whoami')
end
```

## Playing puppet master

Instead of running a puppet master server you can use
Marionetta to orchestrate a number instances.

``` ruby
require 'marionetta'

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

## Using Marionetta in your Rakefile

Marionetta provides an easy mechanism to generate rake tasks
for each of your groups.

In your Rakefile you can do something like so:

``` ruby
require 'marionetta'
require 'marionetta/rake_helper'

staging = Marionetta::Group.new(:staging)

staging.add_server do |s|
  s[:hostname] = 'staging.example.com'
  s[:puppet][:manifest] = 'puppet/manifest.pp'
end

Marionetta::RakeHelper.new(staging).install_group_tasks
```

The tasks `staging:puppet:install` and `staging:puppet:update`
will now be available in your Rakefile.

**Groups must have names if you want to generate rake tasks.**

## Author

Luke Morton a.k.a. DrPheltRight

## License

MIT