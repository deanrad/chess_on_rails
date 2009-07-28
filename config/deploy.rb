set :application, "Chess On Rails"
set :use_sudo, false

#############################################################
#	SCM (Git)
#############################################################

default_run_options[:pty] = true
set :repository,  "git@github.com:chicagogrooves/chess_on_rails.git"
set :scm, "git"
set :branch, "master"
ssh_options[:forward_agent] = true
set :deploy_via, :remote_cache
set :deploy_to, "/home/chicagogrooves/facebook_root/"

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
#	Passenger
#############################################################
 
namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

