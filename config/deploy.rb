set :application, "Chess On Rails"
set :use_sudo, false

#############################################################
#	DEPLOYMENT CONFIGURATION OPTIONS
#############################################################

default_run_options[:pty] = true
set :scm, "git"

# Local repo: 
#     "/Users/dean/src/chess_on_rails.git/"
# Remote repo: 
#     "git@github.com:chicagogrooves/chess_on_rails.git"
# 
set :repository, "git@github.com:chicagogrooves/chess_on_rails.git"

set :git_enable_submodules, 1
set :branch, "master"
ssh_options[:forward_agent] = true

# IMPORTANT OPTION deploy_via: the strategy here affects which
# copy of the code (local or remote) will be deployed
#   :copy - do deploy from local cache of code (eg unpushed code)
#   :remote_cache - to deploy code only which has been pushed
# Also helpful for :copy :
#  set :copy_compression, :gzip
set :deploy_via, :remote_cache
set :copy_compression, :gzip

set :deploy_to, "/home/chicagogrooves/www.chessonrails.com"

#############################################################
#	Servers
#############################################################
 
#production
set :domain, 'chicagogrooves.com'
role :app, domain
role :web, domain
role :db, domain, :primary => true
set :user, 'chicagogrooves'

#############################################################
#	Custom Actions - restarting, db files...
#############################################################
 
namespace :configure do
  task :db do
    run "rm -f #{release_path}/config/database.yml"
    run "ln -s #{shared_path}/chess_on_rails_database.yml #{release_path}/config/database.yml"
  end
  task :env do
    run "rm -f #{release_path}/config/environments/production.rb"
    run "ln -s #{shared_path}/production.rb #{release_path}/config/environments/production.rb"
  end
  task :remove_fb do
    run "rm -rf #{release_path}/vendor/plugins/facebooker"
  end
end

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  after "deploy:update_code", "configure:db", "configure:env", "configure:remove_fb"
end

