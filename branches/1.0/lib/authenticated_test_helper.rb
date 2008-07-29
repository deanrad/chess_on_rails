module AuthenticatedTestHelper
  # Sets the current player in the session from the player fixtures.
  def login_as(player)
    @request.session[:player_id] = player ? players(player).id : nil
  end

  def authorize_as(user)
    @request.env["HTTP_AUTHORIZATION"] = user ? ActionController::HttpAuthentication::Basic.encode_credentials(users(user).login, 'test') : nil
  end
end
