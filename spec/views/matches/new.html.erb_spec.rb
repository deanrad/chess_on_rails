require 'spec_helper'

describe "matches/new" do
  before(:each) do
    assign(:match, stub_model(Match,
      :id => 1,
      :title => "MyString",
      :active => false,
      :inprogress => false
    ).as_new_record)
  end

  it "renders new match form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", matches_path, "post" do
      assert_select "input#match_id[name=?]", "match[id]"
      assert_select "input#match_title[name=?]", "match[title]"
      assert_select "input#match_active[name=?]", "match[active]"
      assert_select "input#match_inprogress[name=?]", "match[inprogress]"
    end
  end
end
