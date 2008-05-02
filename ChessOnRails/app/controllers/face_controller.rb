class FaceController < ApplicationController

  ensure_application_is_installed_by_facebook_user
  ensure_authenticated_to_facebook

  def index
    @userF = session[:facebook_session].user

    @current_player = Player.find( FacebookUser.find(@userF.id).playing_as )
    session[:player_id] = @current_player.id

  end

end
