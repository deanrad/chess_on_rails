class AuthenticationController < ApplicationController

  def login
    return unless request.post?
    
    if user = User.find_by_email_and_security_phrase( params[:email], params[:security_phrase] )
      user.update_attribute(:auth_token, Digest::MD5.hexdigest(Time.now.to_s) )
      cookies[:auth_token] = { :value => user.auth_token, :expires => 1.year.from_now }
      request.player = user.playing_as

      #return them to original page requested, or their homepage
      redirect_to session[:original_uri] || match_index_url
    end

    flash[:notice] = "Your credentials do not check out."
  end
  
  def logout
    session[:player_id] = nil
    cookies[:auth_token] = nil
    redirect_to login_url
  end

end
