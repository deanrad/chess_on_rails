require File.dirname(__FILE__) + '/../spec_helper'

describe 'User model' do
      
  it 'should point to a player' do
    u1 = User.find_by_email "chicagogrooves@gmail.com"

    u1.playing_as.should be_kind_of Player
    u1.playing_as.name.should == "Dean"
    u1.playing_as.id.should   == 1
  end

  it 'should be creatable with the suggested player name' do
    #stupid mocha sideeffect error from use of it in auth_controller.spec - breaks this
    pending do
      u = User.create_with_player( {:email => 'foo@foo.com', :security_phrase => 'x'}, {:name => 'myoplex'} )
      u.should_not be_nil
      u.playing_as.name.should == 'myoplex'
    end
  end
end
