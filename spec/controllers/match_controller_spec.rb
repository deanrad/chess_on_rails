require File.dirname(__FILE__) + '/../spec_helper'

describe MatchController do

  integrate_views

  before(:all) do
    @controller = MatchController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  describe '- status updating' do
    before(:all) do 
    end

    # /match/5/status?move=7
    it 'should get the move number in question from the client' do
      @match = matches(:castled)
      get :status, {:id => @match.id, :last_known_move => @match.moves.length }, { :player_id => players(:dean).id }
      assigns(:as_of_move).should == @match.moves.length
    end

  end

end
