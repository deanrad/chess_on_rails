require 'spec/spec_helper'

describe MatchSession do

  controller_name :matches

  it 'should have a reference to match_session in any controller action' do
    match_session.should_not be_nil
  end

  #it 'should store variables on the match_session with per-match scope' do
  #  get :show, {:id => matches(:dean_vs_paul).id}
  #  the_sess = match_session
  #  the_sess[:set] = "foo"

  #  get :show, {:id => matches(:castled).id}, the_sess
  #  pp session.data
  #  match_session[:set].should != "foo"

  # get :show, {:id => matches(:dean_vs_paul).id}, the_sess
  #  match_session[:set].should == "foo"
  #end

  def match_session; @controller.instance_eval{ match_session } ; end
end
