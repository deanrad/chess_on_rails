# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  #only use layout if not a facebook request - todo - standardize the 'is_facebook' test
  # layout proc{ |c| c.params[:fb_sig] ? false : 'application' }

  # allow descendant controllers to protect their methods against unauthorized access		
  def authorize

    @current_player = Player.find(session[:player_id]) and return if session[:player_id] 


    #else try basic auth for Curl/Wget functionality
    authenticate_with_http_basic do |username, password|
      puts "no player_id, looking up by #{username} and #{password}"
      u = User.find_by_email_and_security_phrase(username, password)
      if u
        @current_player = u.playing_as
        session[:player_id] = @current_player.id 
      end
    end
    return if session[:player_id]
    
    flash[:notice] = "Login is required in order to take this action."
    session[:original_uri] = request.request_uri
    redirect_to login_url
  end

  # Going through this method will end confusion as to how to determine the current player
  #  - whether from session[:player_id], @current_player, facebook info, etc..
  # For now just return the instance variable set by authorize. 
  def current_player
    @current_player
  end
  helper_method :current_player
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery :secret => '81ef9321d36cc23a2671126d90eed60f'
end
