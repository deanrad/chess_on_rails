class AuthenticationController < ApplicationController
	
	#no harm in seeing your options, logging in, or 'logging out', if you're not logged in
	before_filter :authorize, :except=>[:index,:login,:logout]
	
	def login
		user = User.find_by_email_and_security_phrase params[:email], params[:security_phrase]
		
		if user != nil
			@player = user.playing_as
			session[:player_id] = @player.id
			flash[:notice] = "You are logged in."
		else
			flash[:notice] = "Your credentials do not check out."
		end
	end
	
	def logout
		session[:player_id] = nil
	end
	
	#presents the user with their authentication options at this juncture. 
	# not doing so - wouldn't be prudent !
	def index
	end
    
	def change_security_question
	end
end
