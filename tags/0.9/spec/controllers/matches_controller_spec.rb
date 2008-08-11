require File.dirname(__FILE__) + '/../spec_helper'

#TODO fill out the assert_select tests for this when html becomes more stable
describe MatchesController do

  integrate_views #per railscast 71, ensures rendering of views
  
  before(:all) do
    @controller = MatchesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  ##### show action tests ##### 
  
  # the 'white on right rule' - did you know that 50% possible orientations of the board are wrong ?
  it 'should render the board with white square at lower right' do
    login_as(:dean)
    get :show, {:id => matches(:dean_vs_maria).id }
    response.should be_success
    
    response.should have_tag("table.board tr:nth-of-type(8) td:nth-of-type(9)") do
      with_tag ".white"
    end
  end

  it 'should render the board with a1 in the lower left for white' do
    login_as(:dean)
    get :show, {:id => matches(:dean_vs_maria).id }
    response.should be_success
    response.should have_tag("table.board tr:nth-of-type(8) td:nth-of-type(2)#a1") #first row is rank indicator
  end

  it 'should render the board with h8 in the lower left for black' do
    login_as(:maria)
    get :show, {:id => matches(:dean_vs_maria).id }
    response.should be_success
    response.should have_tag("table.board tr:nth-of-type(8) td:nth-of-type(2)#h8") #first row is rank indicator
  end

  ##### index action tests ##### 
  
  it 'renders list of matches for current player' do
    login_as(:dean)
    get :index
    response.should be_success
  end

end
