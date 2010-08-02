set :application, "Chess On Rails"
set :use_sudo, false

#############################################################
#	SCM (Git)
#############################################################

default_run_options[:pty] = true
set :repository,  "git@github.com:chicagogrooves/chess_on_rails.git"
set :scm, "git"
set :git_enable_submodules, 1
set :branch, "master"
ssh_options[:forward_agent] = true
set :deploy_via, :remote_cache
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

