#todo - haven't found a way to get this fully under test - actual facebook requests i can't simulate as far as i can tell

class FbuserController < ApplicationController

   #calling these conditionally allows for running this app under functional test environment
   before_filter { |controller| controller.send(:ensure_authenticated_to_facebook) if controller.params["format"] == "fbml" }
   before_filter { |controller| controller.send(:ensure_application_is_installed_by_facebook_user) if controller.params["format"] == "fbml" }

   # for testing only ! (hack otherwise) simulate facebook authentication with an fb_sig_user post as facebook does
   # (the only reason its a hack is we are not checking the signautre is valid in this version)

  #visiting this controller action will create a session from facebook request info
  def index

    if session[:facebook_session]
	@userF = session[:facebook_session].user
      session[:player_id] = Fbuser.find(@userF.id).playing_as
	@current_player = Player.find( session[:player_id] )
    else
      session[:player_id] = Fbuser.find( params[:fb_sig_user] ).playing_as
	@current_player = Player.find( session[:player_id] )
    end

  end

end
