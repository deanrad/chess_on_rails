require 'spec/spec_helper'
require 'markup_validity'

describe 'MatchesController' do
  controller_name :matches
  integrate_views

  before(:each) do
    @logged_in_session = {:player_id => players(:dean)}
    @match_params = {:match_id => matches(:dean_vs_paul).id}
  end

  describe 'Actions that should render successfully' do
    it 'should render the get method' do
      get :new, {}, @logged_in_session
      response.should be_success
    end
    it 'should render the show method' do
      get :new, @match_params, @logged_in_session
      response.should be_success
    end
  end

=begin
  describe 'Markup validity' do
    it 'Matches/new should validate transitional ' do
      get :new, {}, @logged_in_session

      response.body.should be_xhtml_transitional
    end
  end
=end
end
