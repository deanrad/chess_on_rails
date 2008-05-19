class FbuserController < ApplicationController
   before_filter { |controller| controller.send(:ensure_authenticated_to_facebook) if controller.params["format"] == "fbml" }
   before_filter { |controller| controller.send(:ensure_application_is_installed_by_facebook_user) if controller.params["format"] == "fbml" }

  #ensure_application_is_installed_by_facebook_user
  #ensure_authenticated_to_facebook

  #visiting this controller action will create a session from facebook request info
  def index

    #authenticate the normal facebook way
    #@userF = session[:facebook_session].user


    if session[:facebook_session]
	@userF = session[:facebook_session].user
      @current_player = Player.find( Fbuser.find(@userF.id).playing_as )
    else
      # for testing only ! (hack otherwise) simulate facebook authentication with an fb_sig_user post as facebook does
      # (the only reason its a hack is we are not checking the signautre is valid in this version)

      @current_player = Player.find( Fbuser.find( params[:fb_sig_user] ).playing_as )
    end

  end

end
