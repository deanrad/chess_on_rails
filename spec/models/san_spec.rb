require 'spec/spec_helper'

describe 'SAN' do

  it 'should notate a capture with an x' do
    m = Move.new(:to_coord => 'c3')
    m.stubs(:capture?).returns(true)
    m.stubs(:piece).returns( Knight.new(:white) )
    SAN.from_move(m).should == 'Nxc3'
  end

  it 'should notate non-capturing knight move as Nc3' do
    m = Move.new(:to_coord => 'c3')
    m.stubs(:piece).returns( Knight.new(:white) )
    SAN.from_move(m).should == 'Nc3'
  end

  describe 'pawn moves' do
    it 'a noncapturing push should be notated just by the destination' do
      m = Move.new(:from_coord => 'd2', :to_coord => 'd4')
      m.stubs(:piece).returns( Pawn.new(:white, :d) )
      SAN.from_move(m).should == 'd4'
    end

    it 'a capturing move should be notated by the from coordinate, an x, and the destination' do
      m = Move.new(:from_coord => 'd4', :to_coord => 'e5')
      m.stubs(:piece).returns( Pawn.new(:white, :d) )
      m.stubs(:capture?).returns(true)
      SAN.from_move(m).should == 'dxe5'
    end
  end


end
