require File.dirname(__FILE__) + '/../spec_helper'

describe 'Pawn' do
  before(:all) do
    @white_pawn = Pawn.new(:white, :d)
    @black_pawn = Pawn.new(:black, :d)
    @en_passant = Board[ :d5 => Pawn.new(:white, :d), :c5 => Pawn.new(:black, :c) ]
    @pawn_center = Board[ :d5 => Pawn.new(:black, :d), :e5 => Pawn.new(:black, :e), 
                          :d4 => Pawn.new(:white, :d), :e4 => Pawn.new(:white, :e) ]
    @promotable = Board[:d7 => Pawn.new(:white, :d)]
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
    
    it 'should want to move forward in diagonal direction' do
      moves = @white_pawn.desired_moves_from(:d3)
      moves.should include([1,1])
      moves.should include([1,-1])
    end
    
    it 'should not want to have any additional moves than those specified' do
      @white_pawn.desired_moves_from(:d2).should have(4).items
      @white_pawn.desired_moves_from(:d5).should have(3).items
    end
    
    it 'should not be able to move forward if opponent\'s piece in the way' do
      white_pawn = @pawn_center[:d4]
      white_pawn.unblocked_moves(:d4, @pawn_center).should_not include( [1,0] )
    end

    it 'should be able to move diagonally if capturing' do
      white_pawn = @pawn_center[:d4]
      white_pawn.unblocked_moves(:d4, @pawn_center).should include( [1,1] )
    end
    
    it 'should not be able to move diagonally if not capturing' do
      white_pawn = @pawn_center[:d4]
      white_pawn.unblocked_moves(:d4, @pawn_center).should_not include( [1,-1] ) #no piece there
    end

    it 'should be able to capture doubly advanced pawn as though it were singly advanced (aka enpassant)' do
      #TODO make sure that its double advance was its most recent move (en passant)
      white_pawn = @en_passant[:d5]
      white_pawn.unblocked_moves(:d5, @en_passant).should include( [1,-1] ) #no piece there
    end

    it 'should promote to queen by default upon reaching back rank' do
      match = matches(:unstarted_match)
      board = @promotable
      move = Move.new(:from_coord => :d7, :to_coord => :d8)
      match.board = move.board = board
      
      move.valid?.should == true
      
      match.moves << move
      match.board[:d8].role.should == :queen
      match.board[:d8].kind_of?(Queen).should be_true
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
