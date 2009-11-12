# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Clearance::Authentication
  helper :all # include all helpers, all the time
  include MatchHelper

  # who's authenticated, visible to controllers and views
  attr_accessor :current_player
  def current_player
    @current_player ||= current_user.playing_as
  end
  helper_method :current_player

  # Dont know if we really like this, but better off with it, by default
  protect_from_forgery

end
