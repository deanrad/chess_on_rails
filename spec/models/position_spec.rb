require File.dirname(__FILE__) + '/../spec_helper'

describe Position do

  before(:all) do
    @a5 = Position.new( 'a', '5' )
    @b4 = Position.new( 'b4' )
    @d3 = Position.new( :d3 )
  end
  
  it 'each position has symbol defined' do
    #test one to show our point
    Symbol.all_symbols.any? { |sym| sym.to_s == Position::POSITIONS[0] }.should be_true
  end
  
  it 'can be displayed as string' do
    @d3.to_s.should == 'd3'
  end
  
  it 'can add via vector if stays on board' do
    #a move toward black one unit from a5
    p = @a5 + [1,0] 
    p.to_sym  .should == :a6
    @a5.to_sym #original remains unaltered.should == :a5
  end

  it 'can detect if add via vector falls off board' do
     p = @a5 + [5,5]
      p.valid?.should_not be_true
  end

  it 'adding nonsensical things to position invalidates it' do
    p = @a5 + 'ten'
     p.valid?.should_not be_true
  end

  it 'be callable via class method' do
    Position.as_symbol('d', 4).should == :d4
  end      
  
  it 'should yield the difference between two positions as a vector' do
    p2 = Position.new( :b4 )
    p1 = Position.new( :a4 )
    (p2-p1).should == [0,1]
  end
end
