#todo - haven't found a way to get this fully under test - actual facebook requests i can't simulate as far as i can tell

class FbuserController < ApplicationController

   #calling these conditionally allows for running this app under functional test environment
   before_filter { |controller| controller.send(:ensure_authenticated_to_facebook) if controller.params["format"] == "fbml" }
   before_filter { |controller| controller.send(:ensure_application_is_installed_by_facebook_user) if controller.params["format"] == "fbml" }

   # for testing only ! (hack otherwise) simulate facebook authentication with an fb_sig_user post as facebook does
   # (the only reason its a hack is we are not checking the signautre is valid in this version)

  #visiting this controller action will create a session from facebook request info
  def index

    #users 
    if session[:facebook_session]
	@userF = session[:facebook_session].user

      fb_user = Fbuser.find_by_facebook_user_id(@userF.id)

	#if we dont have them, 'install them
      if fb_user == nil
		fb_user = Fbuser.install( @userF.id ) 
	end

	session[:player_id] = fb_user.playing_as.id
    else
	#this branch taken only by test cases 
      session[:player_id] = Fbuser.find_by_facebook_user_id( params[:fb_sig_user] ).playing_as.id
    end

   authorize #set up instance variables as before

  end

end
