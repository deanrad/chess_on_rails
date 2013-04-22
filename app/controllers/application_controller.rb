require 'request_smarts'
require 'session_smarts'
class ApplicationController < ActionController::Base
  helper :all 

  # helper_attr :current_fbuser  #attr_accessor and helper_method

  before_filter :extend_session_and_request

  # hacks..
  def login_url
    '/authentication/login'
  end

  def extend_session_and_request
    s, r, c, p  = session, request, cookies, params
    r.extend(::RequestSmarts)
    s.extend(::SessionSmarts)
    r.session, r.cookies, r.params = s, c, p
  end

  # HACK - really re-add params and params= to controller ?
  ::RequestSmarts.methods_excluding_ancestors.reject{|m| m.to_s.include?("=")}.each do |m|
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

  # if this request is coming from facebook- its been seen while testing match_controller_fb_spec
  # that sometimes facebook_session is nil in test mode. We'll extend the definition for now to
  # also allow for hacked-on fb_sig_user as well
  def is_facebook?
    return false unless defined? facebook_session
    !! ( facebook_session || params[:fb_sig_user] )
  end

  # # if accessed over facebook, the player referenced
  def player_in_facebook
    fb_id = nil
    if defined? facebook_session
       fb_id = facebook_session ? facebook_session.user.id : params[:fb_sig_user]
    end
    return unless fb_id
    fbuser = Fbuser.find_by_facebook_user_id(fb_id)
    return fbuser.playing_as if fbuser
  end


  #only use layout if not a facebook request - todo - standardize the 'is_facebook' test
  # layout proc{ |c| c.params[:fb_sig] ? false : 'application' }

  # the player this request is being processed for
  def current_player
    p = request.player || player_over_http
    request.player = p if p
  end
  helper_method :current_player

  # descendant controllers call authorize to ensure player is logged in, or redirect them to login
  def authorize
    unless current_player
      flash[:notice] = "Login is required in order to take this action."
      session[:original_uri] = request.fullpath
      redirect_to is_facebook? ? register_url : login_url
    end
  end
  
  protect_from_forgery 
end
