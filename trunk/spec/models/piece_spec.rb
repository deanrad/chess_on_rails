require File.dirname(__FILE__) + '/../spec_helper'

describe Piece do
  
  before(:all) do
    @white_king  = King.new(:white)
    @black_queen= Queen.new(:black)
    @black_queens_bishop = Bishop.new(:black, :queens)
    @white_kings_knight = Knight.new(:white, :kings)
    @white_kings_rook = Rook.new(:white, :kings)
    @d_pawn = Pawn.new(:white, :d)
  end
  
  it 'must be affiliated with a side' do
    lambda{ piece = Piece.new(:king) }.should raise_error
  end
  
  it 'may be a king' do
    @white_king.role.should == :king
  end
  
  it 'may be a queen' do
    @black_queen.role.should == :queen
  end
  
  it 'may be a bishop if you specify which one' do
    @black_queens_bishop.should_not be_nil
  end

  it 'may not be a bishop if you do not specify which one' do
    lambda{ bishop = Bishop.new(:white) }.should raise_error
  end

  it 'may be a knight if you specify which one' do
    @white_kings_knight.should_not be_nil
  end

  it 'may not be a knight if you do not specify which one' do
    lambda{ knight = Knight.new(:white) }.should raise_error
  end

  it 'may be a rook if you specify which one' do
    @white_kings_rook.should_not be_nil
  end

  it 'may not be a knight if you do not specify which one' do
    lambda{ rook = Rook.new(:white) }.should raise_error
  end

  it 'may be a pawn if you specify which one' do
    @d_pawn.should_not be_nil
  end

  it 'may not be a pawn if you do not specify which one' do
    lambda{ pawn = Pawn.new(:white) }.should raise_error
  end
  
  it 'should tell you its desired moves (what it could do on an empty board) from a given position' do
    #desired_moves_from is a common interface to all pieces
    moves = Pawn.new(:white, :d).desired_moves_from( :d3 )
    #in this spec we just care that there are some moves
    moves.should have_at_least(1).item
  end
  
  it 'should not want to fall off the edge of the board' do
    Pawn.new(:white, :d).desired_moves_from( :f8 ).should be_empty
    Knight.new(:black, :d).desired_moves_from( :g8 ).should have(3).items
  end
  
end
