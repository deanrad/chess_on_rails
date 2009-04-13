require File.dirname(__FILE__) + '/../spec_helper'

describe Player do
    
  it "can be created" do
    p = Player.new
    p.should_not be_nil
  end
  
  it "has a name" do
    p = Player.new :name => "Deano"
    p.name.should == "Deano"
  end
  
  it "should not be allowed to register an existing name" do
    p = Player.new :name => players(:dean).name
    p.should_not be_valid
  end

  it "should retrieve matches for a player" do
    p = Player.find(1)
    p.matches.count.should > 1 
  end

  it "should retrieve active matches for a player" do
    p = Player.find(1)
    p.matches.active.count.should > 1 
  end

end
