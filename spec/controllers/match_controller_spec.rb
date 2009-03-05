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
