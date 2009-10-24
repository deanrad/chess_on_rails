# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include MatchHelper

  # who's authenticated, visible to controllers and views
  attr_accessor :current_player
  helper_method :current_player

  # descendant controllers call authorize to ensure player is logged in, or redirect them to login
  def authorize
    self.current_player ||= (player_in_session || player_in_cookie || player_over_http)

    unless self.current_player
      flash[:notice] = "Login is required in order to take this action."
      session[:original_uri] = request.request_uri
      redirect_to :controller => 'authentication' and return false
    end
  end

  # an already logged in player
  def player_in_session
    return nil unless session[:player_id] 
    Player.find(session[:player_id])
  end

  # authenticates from a stored md5 hash in a cookie
  def player_in_cookie
    return nil unless cookies[:auth_token]
    u = User.find_by_auth_token( cookies[:auth_token] )
    u && u.playing_as
  end

  # provides basic auth for Curl/Wget functionality
  def player_over_http
    authenticate_with_http_basic do |username, password|
      User.find_by_email_and_security_phrase(username, password).playing_as
    end
  end

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery :secret => '81ef9321d36cc23a2671126d90eed60f'
end
