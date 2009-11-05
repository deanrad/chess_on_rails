require File.dirname(__FILE__) + '/../spec_helper'
require 'mocha'

describe AuthenticationController do

  before(:all) do 
    @controller  = AuthenticationController.new
    @request     = ActionController::TestRequest.new
    @response    = ActionController::TestResponse.new
  end

  integrate_views

  it 'should render the login page for an unauthorized user' do
    get :index
    response.should be_success
  end

  it 'should render the registration page' do
    get :register
    response.should be_success
  end

  it 'should render a login page' do
    get :login
    response.should be_success
  end

  it 'should display a flash notice if login failed' do
    post :login, { :email => 'xxx@ljskd.com', :security_phrase => 'z' }
    flash[:notice].should_not be_nil
    response.should_not be_redirect
  end

  it 'should set the player id on a successful login' do
    post :login, { :email => users(:dean).email, :security_phrase => users(:dean).security_phrase }
    session[:player_id].should == users(:dean).playing_as.id
  end

  it 'should redirect to matches index page on successful login' do
    post :login, { :email => users(:dean).email, :security_phrase => users(:dean).security_phrase }
    response.should redirect_to( matches_url )
  end

  it 'should clear the session player id on logout' do
    get :logout, {}, { :player_id => 1 }
    session[:player_id].should be_nil
  end

  describe 'cookie-based login persistence via auth_token' do

    it 'should set a cookie upon hitting the tag action' do
      get :tag
      response.cookies.to_s.should include('auth_token')
      # todo - why does this not work ? 
      # response.cookies[:auth_token].should_not be_nil
    end

    it 'should redirect to registration after tagging' do
      get :tag
      response.should redirect_to( :action => 'register' )
    end

    it 'should not overwrite an existing cookie'

  end

  describe 'registration' do
    before(:each) do
      User.expects(:create).returns(User.new)
      Player.expects(:create).returns(players(:dean))
      #Player.any_instance.stubs(:id).returns(7)
    end

    it 'should create a user and player record' do
      post :register, { :player => {:name => 'x'}, 
        :user=>{:security_phrase => 'xx', :email => 'foo@foo.com'} }
    end

    it 'should log a person in' do
      post :register, { :player => {:name => 'x'}, 
        :user=>{:security_phrase => 'xx', :email => 'foo@foo.com'} }
      session[:player_id].should_not be_nil
    end

  end

end
