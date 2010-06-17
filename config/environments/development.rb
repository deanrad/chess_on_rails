# Settings specified here will take precedence over those in config/environment.rb
require 'ruby-debug'

ENV["MAGELLAN_ON"]="1"
HOST = "localhost:3001"

# Allow the attachment of a remote debugger to this process
puts "Starting debugging server... on #{Debugger::PORT}"
puts "Use script/attach [hostname] [port] to connect a debugging application.\n"
Debugger.start_remote()

if File.exist? "#{RAILS_ROOT}/config/breakpoints.rb"
  puts "Loading in custom breakpoints..."
  require 'config/breakpoints'
else
  puts "No custom breakpoints found in config/breakpoints.rb, skipping..."
end

# I sometimes like to give up auto-reloading in order to avoid hard-to-debug
# side-effects of auto-reloading, like the continual loss of class variables. 
# true disables autoreloading - see ActiveSupport::Dependencies.mechanism
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

if config.cache_classes
  puts "Views and Code will NOT be automatically reloaded this session"
else
  puts "Views and Code will be automatically reloaded this session"
end
