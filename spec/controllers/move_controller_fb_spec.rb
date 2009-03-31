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
    facebook_get :index, :fb_sig_user => fbusers(:dean).facebook_user_id
  end

end
