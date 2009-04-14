require File.dirname(__FILE__) + '/../spec_helper'

describe MoveController do 

  before(:all) do
    @controller = MoveController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  it 'should have a flash error upon an invalid move' do
    post :create, {:match_id => 3, :move => { :from_coord =>'e2', :to_coord => 'x9' }  }, {:player_id => 1}
    flash[:move_error].should include('x9 is not a valid')
    
  end
  
  it 'should accept a move via coordinates' do 
    m = matches(:paul_vs_dean)
    
    post :create, { :match_id => m.id, :move => {:from_coord => 'a2', :to_coord => 'a4'} }, {:player_id => m.player1.id}
    assert_response 302
    assert_nil flash[:move_error]

    assert_equal 1, m.reload.moves.length
    assert_not_nil m.moves.last.notation
  end

  it 'should accept a move via notation' do 
    m = matches(:paul_vs_dean)
    post :create, { :match_id => m.id, :notation => 'a4' }, {:player_id => m.player1.id}
    assert_response 302
  end

  it 'should accept a move via ajax' do 
    m = matches(:paul_vs_dean)
    xhr :post, :create, { :match_id => m.id, :notation => 'a4' }, {:player_id => m.player1.id}
    response.should be_success
    assigns[:viewed_from_side].should == :white
  end
  
  it 'should err if specified match not there or active' do
    post :create, { :match_id => 9, :move => {:from_coord => 'e2', :to_coord => 'e4'} }, {:player_id => 1}
    pending {flash[:move_error].should_not be_nil }
  end

  it 'should prohibit moving on a match you dont own' do
    m = matches(:paul_vs_dean)    
    pending do
      lambda{
        post :create, { :match_id => m.id, :move => {:from_coord => 'e2', :to_coord => 'e4'} }, {:player_id => players(:maria).id }
        flash[:move_error].should_not be_nil
      }.should_not raise_error
    end
  end

  it 'should prohibit moving when not your turn' do 
    m = matches(:paul_vs_dean)
    post :create, { :match_id => m.id, :move => {:from_coord=>'e2', :to_coord=>'e4'} }, {:player_id => players(:dean).id }
    flash[:move_error].should_not be_nil
  end

  it 'should end the game when a checkmating move posted' do
    m = matches(:scholars_mate)	

    post :create, { :match_id => m.id, :move => { :notation => 'Qf7' } }, {:player_id => players(:dean).id }		

    m.reload.winning_player.should_not be_nil
    m.active.should == 0
  end

  it 'should redirect to match page (for non ajax move)' do 
    m = matches(:paul_vs_dean)
    post :create, { :match_id => m.id, :move => {:from_coord => 'e2', :to_coord => 'e4'} }, {:player_id => players(:paul).id }
    assert_response :redirect		
  end
  
end
