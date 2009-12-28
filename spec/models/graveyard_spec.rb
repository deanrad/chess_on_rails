require 'spec/spec_helper'

describe Graveyard do
  it 'should start off with 0 points per player' do
    g = Graveyard.new
    g.points_for(:white).should == 0
    g.points_for(:black).should == 0
  end

  it 'should add a pieces point value to the opposing side' do
    g = Graveyard.new; g << p=Pawn.new(:white)
    g.points_for(:white).should == 0
    g.points_for(:black).should == p.point_value
  end

  it 'should reflect the sum of the opponents pieces point value' do
    g = Graveyard.new
    g << p=Pawn.new(:white); g << Pawn.new(:white);
    g << k=Knight.new(:black);
    
    g.points_for(:white).should == k.point_value
    g.points_for(:black).should == 2*p.point_value
  end
end
