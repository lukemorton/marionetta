require 'bundler'
require 'rspec/core/rake_task'
require 'marionetta'

Bundler::GemHelper.install_tasks
RSpec::Core::RakeTask.new(:spec)

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

  unless `git tag -l #{git_tag}`.empty?
    raise 'Version tag already released.'
  end

  cmd = [
    "git tag #{git_tag}",
    "git push origin develop develop:master #{git_tag}",
    "gem push marionetta-#{version}.gem",
  ]
  system(cmd.join(' && '))
end

task(:docs) do
  docs_cmd = [
    'rm -rf docs',
    'cd lib',
    'rocco -o ../docs -l ruby marionetta.rb',
  ]
  system(docs_cmd.join(' && '))
end

task(:clean) do
  system('rm *.gem')
end