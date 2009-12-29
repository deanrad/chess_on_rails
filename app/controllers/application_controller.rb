# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Clearance::Authentication

  helper :all

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
