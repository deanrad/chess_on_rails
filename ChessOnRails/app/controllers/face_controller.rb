class FaceController < ApplicationController

  ensure_application_is_installed_by_facebook_user
  ensure_authenticated_to_facebook

  def index
    @userF = session[:facebook_session].user
  end

end
