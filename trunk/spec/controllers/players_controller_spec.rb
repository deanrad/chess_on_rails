require File.dirname(__FILE__) + '/../spec_helper'
require 'players_controller'

# Re-raise errors caught by the controller.
class PlayersController; def rescue_action(e) raise e end; end

describe PlayersController do

  before(:all) do
    @controller = PlayersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  it 'should allow signup' do
    assert_difference 'Player.count' do
      create_player
      assert_response :redirect
    end
  end

  it 'should require login on signup' do
    assert_no_difference 'Player.count' do
      create_player(:login => nil)
      assigns(:player).errors.on(:login).should_not be_empty
      response.should be_success #template rendering
    end
  end

  it 'should require password on signup' do
    assert_no_difference 'Player.count' do
      create_player(:password => nil)
      assigns(:player).errors.on(:password).should_not be_empty
      assert_response :success
    end
  end

  it 'should require password confirmation on signup' do
    assert_no_difference 'Player.count' do
      create_player(:password_confirmation => nil)
      assigns(:player).errors.on(:password_confirmation).should_not be_empty
      assert_response :success
    end
  end
  
  it 'should require email on signup' do
    assert_no_difference 'Player.count' do
      create_player(:email => nil)
      assigns(:player).errors.on(:email).should_not be_empty
      assert_response :success
    end
  end

  protected
    def create_player(options = {})
      post :create, :player => { :login => 'quire', :email => 'quire@example.com',
        :password => 'quire', :password_confirmation => 'quire' }.merge(options)
    end

end
