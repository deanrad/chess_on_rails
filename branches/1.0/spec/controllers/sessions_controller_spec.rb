require File.dirname(__FILE__) + '/../spec_helper'
require 'sessions_controller'

# Re-raise errors caught by the controller.
class SessionsController; def rescue_action(e) raise e end; end

describe SessionsController do
  # Be sure to include AuthenticatedTestHelper in test/spec_helper.rb instead
  # Then, you can remove it from this and the units test.
  include AuthenticatedTestHelper

  fixtures :players

  before(:all) do
    @controller = SessionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  it 'should login and redirect' do
    post :create, :login => 'dean', :password => '9'
    session[:player_id].should_not be_nil
    assert_response :redirect
  end

  it 'should fail login and not redirect' do
    post :create, :login => 'dean', :password => 'bad password'
    assert_nil session[:player_id]
    assert_response :success
  end

  it 'should logout' do
    login_as :dean
    get :destroy
    assert_nil session[:player_id]
    assert_response :redirect
  end

  it 'should remember me' do
    post :create, :login => 'dean', :password => '9', :remember_me => "1"
    assert_not_nil @response.cookies["auth_token"]
  end

  it 'should not remember me' do
    post :create, :login => 'dean', :password => '9', :remember_me => "0"
    assert_nil @response.cookies["auth_token"]
  end
  
  it 'should delete token on logout' do
    login_as :dean
    get :destroy
    [].should == @response.cookies["auth_token"]
  end

  it 'should login with cookie' do
    players(:dean).remember_me
    @request.cookies["auth_token"] = cookie_for(:dean)
    get :new
    @controller.send(:logged_in?).should be_true
  end

  it 'should fail expired cookie login' do
    players(:dean).remember_me
    players(:dean).update_attribute :remember_token_expires_at, 5.minutes.ago
    @request.cookies["auth_token"] = cookie_for(:dean)
    get :new
    @controller.send(:logged_in?).should_not be_true
  end

  it 'should fail cookie login' do
    players(:dean).remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    @controller.send(:logged_in?).should_not be_true
  end

  protected
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end
    
    def cookie_for(player)
      auth_token players(player).remember_token
    end

end
