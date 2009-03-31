class AuthenticationController < ApplicationController

  # sets the cookie to track who this stranger is - 
  def tag
    cookies[:auth_token] = Digest::MD5.hexdigest(Time.now.to_s)
    redirect_to :action => 'register'
  end

  # a tagged visitor can be prompted to register, and their tag will be 
  # saved with them, along with any name and password info they have chosen
  def register
  end

  def save_registration
    u = User.create_with_player( params[:user], params[:player] ) 
    session[:player_id] = u.playing_as.id
    # current_player = u.playing_as
    redirect_to match_index_url
  end

  #when posting
  def login
    return unless request.post?
    
    user = User.find_by_email_and_security_phrase( params[:email], params[:security_phrase] )
    flash[:notice] = "Your credentials do not check out." and return if !user 

    @player = user.playing_as
    session[:player_id] = @player.id

    #return them to original page requested
    redirect_to session[:original_uri] and return if session[:original_uri]
    
    #or their homepage
    redirect_to match_index_url and return
  end
  
  def logout
    session[:player_id] = nil
    redirect_to login_url
  end

end
