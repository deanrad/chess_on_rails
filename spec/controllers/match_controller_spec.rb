require File.dirname(__FILE__) + '/../spec_helper'

describe MatchController do

  integrate_views

  before(:all) do
    @controller = MatchController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  it 'should allow POST creation of a match between two player_ids' do
    post :create, {:opponent_id => 3, :opponent_side => 'black'}, {:player_id => players(:dean).id }

    match = assigns[:match]

    match.should_not be_nil
    response.should redirect_to( :controller => :match, :action => :show, :id => match.id )
    match.player2.should == Player.find(3)
  end

  it 'should show a match requested' do
    get :show, {:id => matches(:dean_vs_paul).id},  {:player_id => players(:dean).id }
    assigns[:match].should_not be_nil
  end

  it 'should render a form for a new match' do
    get :new, {},  {:player_id => players(:dean).id }
    pending{ assigns[:match].should be_a_new_record }
  end

  it 'should populate the start position for a new match if FEN given' do
    post :create, {:opponent_id => 3, :opponent_side => 'black', :start_pos => 'R7/8/8/8/8/8/8/8'},  {:player_id => players(:dean).id }
    assigns[:match].start_pos.should == 'R7/8/8/8/8/8/8/8'
  end

  it 'should create moves for a new match if PGN given' do
    post :create, {:opponent_id => 3, :opponent_side => 'black', :start_pos => '1. e4'},  {:player_id => players(:dean).id }
    assigns[:match].moves.count.should == 1
    assigns[:match].moves[0].notation.should == 'e4'
  end

  it 'should allow resignation via POST' do
    post :resign , {:id => matches(:dean_vs_paul).id},  {:player_id => players(:dean).id }
    assigns[:match].should_not be_active
  end
  
  it 'should show any current move queue in the page' do
    get :show, {:id => matches(:dean_vs_paul).id, :format => 'html'}, {:player_id => players(:dean).id }

    response.should have_tag("div#this_move_queue", :text => 'Nc4 b5')
  end

  describe '- status updating' do
    before(:all) do 
    end

    # /match/5/status?move=8, white queries if the 8th move has been made by black yet
    it 'should detect that the client does not need updating if it sends current value of move param' do
      @match = matches(:castled) #paul white, dean black, dean to move
      get :status, { :id => @match.id, :move => @match.moves.length + 1 }, { :player_id => players(:paul).id }
      assigns(:status_has_changed).should be_false
    end

    # /match/5/status?move=8, black queries if the status has changed for move 7
    it 'should detect that the client needs updating if it sends old value of move param' do
      @match = matches(:castled)
      get :status, { :id => @match.id, :move => (@match.moves.length) }, { :player_id => players(:dean).id }
      assigns(:status_has_changed).should be_true
    end

  end

end
