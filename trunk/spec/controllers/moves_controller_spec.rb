require File.dirname(__FILE__) + '/../spec_helper'

describe MovesController, 'Posting an erroneous move' do
  
  integrate_views
  
  before(:all) do

    @controller = MovesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
  end

  it 'should display an error if you make an invalid move' do
    post :create, {:match_id => matches(:dean_vs_maria).id, :move => {:from_coord => 'a4', :to_coord => 'd4'} }
    
    flash[:move_in_error].should_not be_nil 
    response.should be_redirect
    
    #TODO [RSpec] how do we verify that the flash be rendered into the page
  end
  
=begin
  do
    post :create, {:match_id => ''}
    response.headers["Status"].should == "404 Not Found" #pretty low-level !
  end
=end  
  
end

