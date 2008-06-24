# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
	helper :all # include all helpers, all the time

	before_filter :detect_facebook

	#only use layout if not a facebook request - todo - standardize the 'is_facebook' test
	layout proc{ |c| c.params[:fb_sig_user] ? false : 'application' }
		
	def authorize

		if Player.find_by_id session[:player_id] 
			@current_player = Player.find( session[:player_id] )
		else
			flash[:notice] = "Login is required in order to take this action."
			session[:original_uri] = request.request_uri
			redirect_to :controller=>"authentication", :action=>"login"
		end
	end

private

	def detect_facebook
		
		#set easy accessor
		def self.facebook?
			#todo need to make sure this can't be faked
			! params[:fb_sig_user].blank?
		end

		return unless facebook?

		#set who it is
		session[ :facebook_user_id ] = params[:fb_sig_user].to_i

		return if session[:player_id]

		#if known, authorize them
		fb_user = Fbuser.find_by_facebook_user_id( params[:fb_sig_user] )
		session[ :player_id ] = fb_user.playing_as.id  if (fb_user)
	end	

	# See ActionController::RequestForgeryProtection for details
	# Uncomment the :secret if you're not using the cookie session store
	protect_from_forgery :secret => '81ef9321d36cc23a2671126d90eed60f'
end
