# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all 

  # helper_attr :current_fbuser  #attr_accessor and helper_method

  before_filter :extend_session_and_request

  def extend_session_and_request
    s, r, c, p  = session, request, cookies, params
    r.extend(RequestSmarts)
    r.session, r.cookies, r.params = s, c, p
  end

  RequestSmarts.methods_excluding_ancestors.each do |m|
    helper_method m.to_sym 
    define_method m do request.send(m) end
  end

  #only use layout if not a facebook request - todo - standardize the 'is_facebook' test
  # layout proc{ |c| c.params[:fb_sig] ? false : 'application' }

  # descendant controllers call authorize to ensure player is logged in, or redirect them to login
  def authorize
    unless request.player
      flash[:notice] = "Login is required in order to take this action."
      session[:original_uri] = request.request_uri
      redirect_to is_facebook? ? register_url : login_url
    end
  end
  
  protect_from_forgery 
end
