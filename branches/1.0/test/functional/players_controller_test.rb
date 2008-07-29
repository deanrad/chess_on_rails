require File.dirname(__FILE__) + '/../test_helper'
require 'players_controller'

# Re-raise errors caught by the controller.
class PlayersController; def rescue_action(e) raise e end; end

class PlayersControllerTest < Test::Unit::TestCase

  def setup
    @controller = PlayersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_allow_signup
    assert_difference 'Player.count' do
      create_player
      assert_response :redirect
    end
  end

  def test_should_require_login_on_signup
    assert_no_difference 'Player.count' do
      create_player(:login => nil)
      assert assigns(:player).errors.on(:login)
      assert_response :success
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference 'Player.count' do
      create_player(:password => nil)
      assert assigns(:player).errors.on(:password)
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference 'Player.count' do
      create_player(:password_confirmation => nil)
      assert assigns(:player).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference 'Player.count' do
      create_player(:email => nil)
      assert assigns(:player).errors.on(:email)
      assert_response :success
    end
  end
  

  

  protected
    def create_player(options = {})
      post :create, :player => { :login => 'quire', :email => 'quire@example.com',
        :password => 'quire', :password_confirmation => 'quire' }.merge(options)
    end

end
