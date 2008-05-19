class AuthenticationController < ApplicationController
	
	#no harm in seeing your options, logging in, or 'logging out', if you're not logged in
	before_filter :authorize, :except=>[:login,:logout]
	
	#when posting
	def login
		user = User.find_by_email_and_security_phrase( params[:email], params[:security_phrase] )
		
		if user != nil
			@player = user.playing_as
			session[:player_id] = @player.id
			flash[:notice] = "Welcome, #{@player.name}."

			#return them to original page requested
			if session[:original_uri]
				redirect_to session[:original_uri] and return
			else
				redirect_to '/match/' and return
			end
		else
			flash[:notice] = "Your credentials do not check out." if params[:email] 
		end
	end
	
	def logout
		session[:player_id] = nil
		redirect_to :action => 'login'
	end

end
