require File.dirname(__FILE__) + '/../spec_helper'

describe 'User model' do
      
  it 'should point to a player' do
    u1 = User.find_by_email "chicagogrooves@gmail.com"

    u1.playing_as.should be_kind_of Player
    u1.playing_as.name.should == "Dean"
    u1.playing_as.id.should   == 1
  end

end
