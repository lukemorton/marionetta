require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'marionetta'

task(:default => :spec)

task(:gem => :spec) do
  cmd = [
    'git add -A',
    'git stash',
    'gem build marionetta.gemspec',
    'git stash pop',
    'git reset',
  ]
  system(cmd.join(' && '))
end

task(:publish => :gem) do
  version = Marionetta::VERSION
  git_tag = "v#{version}"

  if `git tag -l #{git_tag}`
    raise 'Version tag already released.'
  end

  cmd = [
    "git tag #{git_tag}",
    "git push origin develop develop:master #{git_tag}",
    "gem push marionetta-#{version}.gem",
  ]
  system(cmd.join(' '))
end

task(:clean) do
  system('rm -rf *.gem')
end