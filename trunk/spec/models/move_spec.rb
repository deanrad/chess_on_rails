require File.dirname(__FILE__) + '/../spec_helper'

describe Move do

  it "should be invalid without a from and to coordinate" do
    m = Move.new( :from_coord => :d4 )
    m.valid?.should == false
  end
  
  it 'can create a move with valid from and to coordinates as symbols' do
    m = Move.new(:from_coord => :a2, :to_coord => :a4)
    m.from_coord.should == :a2
    m.to_coord.should == :a4
  end
  
  it 'move comes back from database as symbols' do
    matches(:dean_vs_maria).moves.first.to_coord.should == :d4
  end

end
