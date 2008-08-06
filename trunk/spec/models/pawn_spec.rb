require File.dirname(__FILE__) + '/../spec_helper'

describe Piece, 'Pawn' do
  before(:all) do
    @white_pawn = Pawn.new(:white, :d)
    @black_pawn = Pawn.new(:black, :d)
  end
  
  describe 'White' do
    it 'should want to advance +2 ranks if on its initial square' do
      moves = @white_pawn.desired_moves_from(:d2)
      moves.should include([2,0])
    end
  
    it 'should not want to go forward +2 ranks if on any other square' do
      moves = @white_pawn.desired_moves_from(:d3)
      moves.should_not include([2,0])
    end
    
    it 'should want to move forward in diagonal direction towards capture' do
      moves = @white_pawn.desired_moves_from(:d3)
      moves.should include([1,1])
      moves.should include([1,-1])
    end
    
    it 'should not have any additional moves than those specified' do
      @white_pawn.desired_moves_from(:d2).should have(4).items
      @white_pawn.desired_moves_from(:d5).should have(3).items
    end
  end  
  
  describe 'Black' do
    it 'should want to advance -2 ranks if on its initial square' do
      moves = @black_pawn.desired_moves_from(:f7)
      moves.should include([-2,0])
    end

    it 'should not want to advance -2 ranks if on any other square' do
      moves = @black_pawn.desired_moves_from(:f5)
      moves.should_not include([-2,0])
    end
  end
end
