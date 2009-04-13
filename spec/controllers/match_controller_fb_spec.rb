require File.dirname(__FILE__) + '/../spec_helper'

#Facebook Tests
describe MatchController do 
  include Facebooker::Rails::TestHelpers

  before(:all) do
    @controller = MatchController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  it 'should get the matches page from facebook for a known user' do
    lambda{
      facebook_get :index, :fb_sig_user => fbusers(:dean).facebook_user_id
    }.should_not raise_error
    response.should be_success
    assert_template 'match/index'
  end

  it 'should redirect to register page for unknown facebook user' do
    facebook_get :index, :fb_sig_user => '0000007'
    response.should be_success
  end

end
