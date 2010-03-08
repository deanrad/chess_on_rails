# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '>= 2.2.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

require 'digest/md5'

Rails::Initializer.run do |config|

  config.action_controller.session_store = :active_record_store
  config.action_controller.session = {
    :session_key => '_ChessOnRails_session',
    :secret      => '0f323b68e4ad062184c40478479bbf96168cf7023719b06f12930b9764e3075616f60c7287e45de9603dcddebef13cc7ca445ab925179bdc0313fdf15314dc94'
  }

  config.gem "clearance",
  :lib     => 'clearance',
  :source  => 'http://gemcutter.org',
  :version => '0.8.3'

  config.gem 'justinfrench-formtastic', :lib => 'formtastic', :source => 'http://gems.github.com'

end

DO_NOT_REPLY = "donotreply@chessonrails.com"
