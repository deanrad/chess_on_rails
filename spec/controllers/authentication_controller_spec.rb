require File.dirname(__FILE__) + '/../spec_helper'

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
    it 'should not do tagging for facebook sessions (unless proven harmless)'

  end

  describe 'registration' do
    it 'should log a person in upon registration' do
      post :register, { :player => {:name => 'x'}, 
        :user=>{:security_phrase => 'xx', :email => 'foo@foo.com'} }
      session[:player_id].should_not be_nil
    end

    it 'should render with save_registration as the form post location' 
  end

  it 'should stay on login screen upon failed login'
end
