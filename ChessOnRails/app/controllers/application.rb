# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
	helper :all # include all helpers, all the time

	#turn off body and other such elements pulled in from layout for facebook
	layout proc{ |c| c.params[:fb_sig] ? false : "application" }

	#otherwise we use the same templates for now so maintain html format		
	def fbml_cleanup
		params[:format]='html' if params[:format]=='fbml'
	end

		
	def authorize
		if Player.find_by_id session[:player_id] 
			@current_player = Player.find( session[:player_id] )
		else
			flash[:notice] = "Login is required in order to take this action."
			session[:original_uri] = request.request_uri
			redirect_to :controller=>"authentication", :action=>"login"
		end
	end
	
	# See ActionController::RequestForgeryProtection for details
	# Uncomment the :secret if you're not using the cookie session store
	protect_from_forgery :secret => '81ef9321d36cc23a2671126d90eed60f'
end
