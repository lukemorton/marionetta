require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task(:default => :spec)

task(:gem) do
  cmd = [
    'git add -A',
    'git stash',
    'gem build marionetta.gemspec',
    'git stash pop',
    'git reset',
  ]
  system(cmd.join(' '))
end