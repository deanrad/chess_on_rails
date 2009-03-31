# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  helper_attr :current_fbuser  #attr_accessor and helper_method
  attr_accessor :current_player
  helper_method :current_player

  #only use layout if not a facebook request - todo - standardize the 'is_facebook' test
  # layout proc{ |c| c.params[:fb_sig] ? false : 'application' }

  # descendant controllers call authorize to ensure player is logged in, or redirect them to login
  def authorize
    self.current_player ||= player_in_session || player_in_facebook || player_in_cookie || player_over_http

    unless self.current_player
      flash[:notice] = "Login is required in order to take this action."
      session[:original_uri] = request.request_uri
      redirect_to is_facebook? ? register_url : login_url
    end
  end


  private

  # if this request is coming from facebook- its been seen while testing match_controller_fb_spec
  # that sometimes facebook_session is nil in test mode. We'll extend the definition for now to
  # also allow for hacked-on fb_sig_user as well
  def is_facebook?
    !! ( facebook_session || params[:fb_sig_user] )
  end

  # an already logged in player
  def player_in_session
    return nil unless session[:player_id] 
    Player.find(session[:player_id])
  end

  # if accessed over facebook, the player referenced
  def player_in_facebook
    fb_id = facebook_session ? facebook_session.user.id : params[:fb_sig_user]
    return unless fb_id
    fbuser = Fbuser.find_by_facebook_user_id(fb_id)
    return fbuser.playing_as if fbuser
  end

  # authenticates from a stored md5 hash in a cookie
  def player_in_cookie
    return nil unless cookies[:auth_token]
    User.find_by_auth_token( cookies[:auth_token] ).playing_as
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
