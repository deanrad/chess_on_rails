# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
	helper :all # include all helpers, all the time

	#this is invoked prior to derived classes' authorize messages
	before_filter :detect_facebook

	#only use layout if not a facebook request - todo - standardize the 'is_facebook' test
	layout proc{ |c| c.params[:fb_sig] ? false : 'application' }

	#in advance of the call to authorize, detect_facebook infers authorization information
	# from facebook request headers
	def detect_facebook

		return if params[:fb_sig_user].blank?

		#set who it is
		session[ :facebook_user_id ] = params[:fb_sig_user].to_i

		#if unknown set no more variables - let authorize kick them out
		fb_user = Fbuser.find_by_facebook_user_id( params[:fb_sig_user] )
		return unless fb_user

		#now set session and instance variables for authorize
		session[ :player_id ] = fb_user.playing_as.id  
		@current_player = Player.find( session[ :player_id ] )
	end	


	# allow descendant controllers to protect their methods against unauthorized access		
	def authorize

		return if @current_player 

		@current_player = Player.find(session[:player_id]) if session[:player_id] 
		
		unless @current_player
			flash[:notice] = "Login is required in order to take this action."
			session[:original_uri] = request.request_uri
			redirect_to :controller=>"authentication", :action=>"login"
		end
	end

	# See ActionController::RequestForgeryProtection for details
	# Uncomment the :secret if you're not using the cookie session store
	protect_from_forgery :secret => '81ef9321d36cc23a2671126d90eed60f'
end
