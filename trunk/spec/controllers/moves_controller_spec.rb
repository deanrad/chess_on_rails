require File.dirname(__FILE__) + '/../spec_helper'

describe MovesController do
  
  integrate_views
  
  before(:all) do

    @controller = MovesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @nonsensical_first_move = {:from_coord => 'a4', :to_coord => 'd4'} 
    @logical_first_move =     {:from_coord => 'd2', :to_coord => 'd4'} 
  end

  it 'should display an error if you make an invalid move' do
    
    @unstarted_match = matches(:unstarted_match)
    post :create, {:match_id => @unstarted_match.id, :move => @nonsensical_first_move }
    
    flash[:move_in_error].should_not be_nil 
    response.should be_redirect
    
    #TODO [RSpec] how do we verify that the flash be rendered into the page
  end
  
  it 'should allow you to make a valid move' do 
    @unstarted_match = matches(:unstarted_match)
    post :create, {:match_id => @unstarted_match.id, :move => @logical_first_move }

    @unstarted_match.moves.count.should == 1
  end
  
=begin
  do
    post :create, {:match_id => ''}
    response.headers["Status"].should == "404 Not Found" #pretty low-level !
  end
=end  
  
end

