require File.expand_path( File.dirname(__FILE__) + '/../spec_helper' )

describe Gameplay do

  it "should link a player to a match" do
    with matches(:dean_vs_paul).gameplays do |gps|
      gps.white.player.should == players(:dean)
      gps.black.player.should == players(:paul)
    end
  end

  # it "should link a maximum of two players to a match"
  
  it "should be able to store a move queue for a player (low-level)" do
    with matches(:dean_vs_paul).gameplays[0] do |gp|
      gp[:move_queue].should_not be_nil
    end
  end

  it "should return a move queue object for a player" do
    with matches(:dean_vs_paul).gameplays[0] do |gp|
      gp.move_queue.should_not be_nil
    end
  end
end
