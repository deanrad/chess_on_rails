# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

# require 'metric_fu'

# not merging with rails own predefined rake task yet..
# GOAL: Eventually report on JS, comments, etc, through extensible lambda-based infrastructure
# as opposed to hacking within a for-loop
# 

task :test => [:spec]
# Backward compatibility with Test::Unit fixture loading style
namespace :db do
  namespace :fixtures do
    task :load => [:"spec:db:fixtures:load"]
  end
end
#namespace :analyze do

  desc "Report statistics (lines, lines of ERB, etc) about the views in this application"
  task :analyze_stats => [:stats] do
    
    require 'misc/view_statistics'
    ViewStatistics.new( *[
      %w(Views             app/views)
    ]).to_s

  end

#end
