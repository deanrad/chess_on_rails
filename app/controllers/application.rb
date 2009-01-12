# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  #only use layout if not a facebook request - todo - standardize the 'is_facebook' test
  layout proc{ |c| c.params[:fb_sig] ? false : 'application' }

  #in advance of the call to authorize, detect_facebook infers authorization information
  # from facebook request headers
  def detect_facebook
    session[:facebook_user_id]= params[:fb_sig_user].to_i if RAILS_ENV == 'test' && !params[:fb_sig_user].blank?

    unless session[:facebook_user_id]
      return unless session[:facebook_session]
      session[:facebook_user_id]= session[:facebook_session].user.id
    end

    fb_user = Fbuser.find_by_facebook_user_id( session[:facebook_user_id] )
    return unless fb_user

    session[:player_id] = fb_user.playing_as.id
  end	


  # allow descendant controllers to protect their methods against unauthorized access		
  def authorize
    detect_facebook unless session[:player_id] 

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
    redirect_to login_url unless params[:format]=='fbml'
  end

  #given a @match and @current_player, sets up other instance variables 
  def set_match_status_instance_variables
    @files = Chess::Files
    @ranks = Chess::Ranks.reverse

    @board = @match.board

    @viewed_from_side = (@current_player == @match.player1) ? :white : :black
    @your_turn = @match.turn_of?( @current_player )

    if @viewed_from_side == :black
      @files.reverse!
      @ranks.reverse!
    end

    @last_move = @match.reload.moves.last

    # too small to refactor away - but indicates whether the status has changed since last requested
    session[:move_count] ||= @match.moves.length 
    @status_has_changed  = ( session[:move_count] != @match.moves.length )
    session[:move_count] = @match.moves.length
  end	
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery :secret => '81ef9321d36cc23a2671126d90eed60f'
end
