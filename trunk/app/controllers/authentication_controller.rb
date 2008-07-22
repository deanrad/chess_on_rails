class AuthenticationController < ApplicationController
  
  #no harm in seeing your options, logging in, or 'logging out', if you're not logged in
  before_filter :authorize, :except => [:index,:login,:logout]
  
  #when posting
  def login
    return unless request.post?
    
    user = User.find_by_email_and_security_phrase( params[:email], params[:security_phrase] )
    flash[:notice] = "Your credentials do not check out." and return if !user 

    @player = user.playing_as
    session[:player_id] = @player.id

    #return them to original page requested
    redirect_to session[:original_uri] and return if session[:original_uri] and params[:format] != 'fbml'
    
    #or their homepage
    redirect_to matches_url and return
  end
  
  def logout
    session[:player_id] = nil
    redirect_to login_url
  end

end
