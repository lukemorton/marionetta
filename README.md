# Marionetta

[Marionetta][marionetta] is a ruby library for executing
commands on one or more remote machines via SSH.

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

[marionetta]: http://drpheltright.github.com/marionetta/

## Documentation

Marionetta has [annotated source][docs] that provides the
bulk of documentation for Marionetta. Hopefully you'll find
the annotations informative on *how to use* this library. If
you feel they could be improved please create an issue on
GitHub.

If you prefer looking at the code, check it out on [github][github].

[docs]: http://drpheltright.github.com/marionetta/docs/marionetta.html
[github]: http://github.com/DrPheltRight/marionetta/

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
  s[:ssh][:flags] << ['-i', 'keys/private.key']
  s[:puppet][:manifest] = 'puppet/manifest.pp'
  s[:deployer][:from] = '/my-app'
  s[:deployer][:to] = '/home/staging/www'
end

Marionetta::RakeHelper.install_group_tasks(staging)
```

The tasks `puppet:staging:install`, `puppet:staging:update`,
`deployer:staging:deploy` and `deployer:staging:rollback`
will now be available in your Rakefile.

## Defining a group of servers

Marionetta allows you to describe and manipulate a number of
servers in parallel via SSH. First you need to define a group
of servers:

``` ruby
require 'marionetta/group'

servers = Marionetta::Group.new(:production)

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

servers = Marionetta::Group.new(:production)

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

## Upcoming

 - Add permissions with Manipulators::Deployer (v0.4.x)
 - Remove rollback feature... we don't need rollbacks IMO. (v0.5.x)
 - Remove Marionetta::Manipulators::Debloyer (v0.5.x) 
 - Use rye for commands (https://github.com/delano/rye) (v0.5.x)
 - Use a single SSH connection per task (v0.5.x)
 - Ensure concurrency is tested and therefore guaranteed (v0.5.x)

## Author

Luke Morton a.k.a. DrPheltRight

## Collaborating

Create an issue and send a pull request if you get any bright
ideas or have a fix. Feel free to create an issue and not send
one too, feedback is always welcome.

## Testing

To test run this on your command line:

```
rake
```

You need to ensure `spec/vagrant/key` has `0600` permissions.

## Generating documentation

Generate documentation using the following command:

```
rake doc
```

Publishing the documentation to GitHub pages is a little messy
to say the least. Try this:

```
rake doc
mv docs docs-new
git checkout gh-pages
rm -rf docs
mv -f docs-new docs
git add docs
git commit -m "Update documentation."
git push origin gh-pages
```

## License

Licensed under MIT by Luke Morton, 2012.
