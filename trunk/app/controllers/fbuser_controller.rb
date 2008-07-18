#todo - haven't found a way to get this fully under test - actual facebook requests i can't simulate as far as i can tell

class FbuserController < ApplicationController	

  before_filter :authenticate_to_facebook

  def index
    detect_facebook
  end

  def register
    @fb_user = Fbuser.find_by_facebook_user_id( params[:fb_sig_user] )

    @fb_user.name = params[:name] and redirect_to( 'index' ) and return if @fb_user

    #else we don't know them - set them up 
    p = Player.create( :name => params[:name] )
    @fb_user = Fbuser.create( :facebook_user_id => params[:fb_sig_user], :playing_as => p )

    #give them a match with me just to start
    Match.create( :player1 => p, :player2 => Player.find(1) )

    #sign them in 
    session[:player_id] = p.id

    redirect_to( :controller => 'match', :action => 'index' )
  end

private

  #requires in all environments other than TEST we redirect to facebook authentication
  # via the facebooker command ensure_authenticated_to_facebook
  def authenticate_to_facebook
    params[:format]='fbml'

    send(:ensure_authenticated_to_facebook) and return unless RAILS_ENV == 'test' && params[:fb_sig_user]

    #code running only for the TEST environment
    #send(:ensure_authenticated_to_facebook) and return unless @current_player
  end
end

