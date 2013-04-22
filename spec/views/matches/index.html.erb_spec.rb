require 'spec_helper'

describe "matches/index" do
  
  
  subject(:matches) { [FactoryGirl.create(:match)] }
  before :each do
    assign(:matches, matches)
  end

  it "renders a list of matches" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 1
  end
end
