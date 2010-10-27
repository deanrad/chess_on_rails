# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all 

  before_filter :extend_session_and_request

  def extend_session_and_request
    s, r, c, p  = session, request, cookies, params
    r.extend(RequestSmarts)
    s.extend(SessionSmarts)
    r.session, r.cookies, r.params = s, c, p
  end

  # HACK - really re-add params and params= to controller ?
  RequestSmarts.methods_excluding_ancestors.reject{|m| m.to_s.include?("=")}.each do |m|
    helper_method m.to_sym 
    define_method m do request.send(m) end
  end

  # provides basic auth for Curl/Wget functionality
  def player_over_http
    u = nil
    authenticate_with_http_basic do |username, password|
      u = User.find_by_email_and_security_phrase(username, password)
    end
    return u && u.playing_as
  end

  # the player this request is being processed for - should be request.player but...
  def current_player
    p = request.player || player_over_http
    request.player = p if p
  end
  helper_method :current_player

  # descendant controllers call authorize to ensure player is logged in, or redirect them to login
  def authorize
    unless current_player
      flash[:notice] = "Login is required in order to take this action."
      session[:original_uri] = request.request_uri
      redirect_to login_url
    end
  end
  
  protect_from_forgery 
end
