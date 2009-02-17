require File.dirname(__FILE__) + '/../spec_helper'

describe Player, "A player" do
    
  it "can be created" do
    p = Player.new
    p.should_not be_nil
  end
  
  it "stores a name" do
    name = "Deano"
    p = Player.new :name => name
    p.name.should == name
  end
  
  it "should not be allowed to register an existing name" do
    # warning - frail test dependent on fixtures
    #already one named Dean loaded by fixture
    p = Player.new :name => "Dean"
    p.should_not be_valid
  end

end
