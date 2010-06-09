require 'spec/spec_helper'

describe 'MatchesController' do
  controller_name :matches
  integrate_views

  before(:each) do
    @controller.current_user= users(:dean)
    @match_params = {:id => matches(:dean_vs_paul).id}
  end

  describe 'Actions that should render successfully' do
    it 'should render the get method' do
      get :new, {}
      response.should be_success
    end
    it 'should render the show method' do
      get :new, @match_params
      response.should be_success
    end
    it 'should render the status method' do
      get :status, @match_params
      response.should be_success
    end
    it 'should route to a match' do
      m = nil
      @controller.instance_eval{ 
        match_path( m = Match.first )
      }.should == "/matches/#{m.id}"
    end 
  end

=begin
  describe 'Markup validity' do
    it 'Matches/new should validate transitional ' do
      get :new, {}

      response.body.should be_xhtml_transitional
    end
  end
=end
end
