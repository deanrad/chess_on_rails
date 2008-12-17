require File.dirname(__FILE__) + '/../spec_helper'

describe Sides do
  it 'should have a white side' do
    Sides::White.should_not be_nil
  end
  it 'should have a black side' do
    Sides::Black.should_not be_nil
  end
  it 'should be able to retrieve a side by its name/symbol' do
    Sides[:black].should == Sides::Black
    Sides[:white].should == Sides::White
    Sides[:other].should be_nil
  end
  
  it 'should return exactly two sides' do
    i=0; Sides.each {i+=1}
    i.should == 2
  end
  
  describe 'White' do
    it 'should advance in the direction of ascending ranks (+1)' do
      Sides::White.advance_direction.should == 1
    end
    
  end

  describe 'Black' do
    it 'should advance in the direction of descending ranks (-1)' do
      Sides::Black.advance_direction.should == -1
    end
    
  end
end