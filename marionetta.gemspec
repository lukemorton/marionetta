require File.dirname(__FILE__)+'/lib/marionetta'

Gem::Specification.new do |s|
  s.name        = "marionetta"
  s.version     = Marionetta::VERSION
  s.homepage    = 'https://github.com/DrPheltRight/marionetta'
  s.authors     = ["Luke Morton"]
  s.email       = ["lukemorton.dev@gmail.com"]
  s.summary     = "Provision using puppet and deploy your servers over SSH."
  s.description = "Marionetta is a ruby library for executing commands to one
                   or more remote machines via SSH. It provides puppet
                   provisioning without the need for a puppet master and can
                   also deploy your application code (with rollbacks) via
                   rsync. With a RakeHelper you can integrate it into your
                   workflow with ease."
                   
  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- spec/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map {|f| File.basename(f)}

  s.require_paths = ["lib"]

  s.add_dependency('open4')
  s.add_dependency('celluloid')
  s.add_dependency('fpm')

  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')
  s.add_development_dependency('vagrant')
end