# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Clearance::Authentication
  # override this clearance method to do eager loading
  def user_from_cookie
    if token = cookies[:remember_token]
      ::User.find_by_remember_token(token, :include => :playing_as)
    end
  end
  protected :user_from_cookie

  helper :all

  include MatchHelper


  # Gives controllers access to a 'smart' object with methods instead of a
  # hash acting like a global variable
  def match_session
    # MatchSession.new(session, params[:match_id] || params[:id] )
    session[:matches] ||= {}
    session[:matches][ params[:match_id] || params[:id] ] ||= {}
  end
  helper_method :match_session


  # who's authenticated, visible to controllers and views
  helper_method :current_player
  attr_accessor :current_player
  def current_player
    @current_player ||= current_user && current_user.playing_as
  end

  # Dont know if we really like this, but better off with it, by default
  protect_from_forgery

  ## Clearance Admin methods follow
  helper_method :signed_in_as_admin?
  helper_method :show_admin_content?
  
  def signed_in_as_admin?
    signed_in? && current_user.admin?
  end

  def show_admin_content?
    signed_in_as_admin?
  end
  
  def users_only
    deny_access("Please Login or Create an Account to Access that Feature.") unless signed_in?
  end
  
  def admin_only
    deny_access("Please Login as an administrator to Access that Feature.") unless signed_in_as_admin?
  end

end
