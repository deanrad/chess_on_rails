require File.dirname(__FILE__) + '/../spec_helper'

describe "Facebook User" do

  it "can update name after signing in" do
    fb = Fbuser.find_by_facebook_user_id( fbusers(:dean).facebook_user_id )
    
    fb.name = expected = 'Deanoxyz'

    fb.reload.playing_as.name.should == expected
    fb.name.should == expected
  end

  it 'enhances player class with facebook_id' do
    players(:dean).facebook_id.should_not be_nil
    players(:chris).facebook_id.should    be_nil
  end
end
