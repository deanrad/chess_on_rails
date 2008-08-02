require File.dirname(__FILE__) + '/../spec_helper'

describe Board do
  
  before(:all) do
    @rook = Piece.new(:rook, :white )
    @white_king, @white_queen = [ Piece.new(:king, :white), Piece.new(:queen, :white) ]
    @black_king, @black_queen = [ Piece.new(:king, :black), Piece.new(:queen, :black) ]

    @lone_rook_board = Board[ :a1 => @rook ]
    @initial_board = Board.initial_board    
    @kings_and_queens= Board[ :d1 => @white_queen, :e1 => @white_king, :d8 => @black_queen, :e8 => @black_king ]
  end
  
  it 'should be able to store a piece on a specified square' do
    @lone_rook_board[:a1].role.should == :rook
  end

  it 'should be able to undo a considered move' do
    @lone_rook_board[:a1].should == @rook
    
    @lone_rook_board.consider_move( Move.new( :from_coord => :a1, :to_coord => :a8) ) do
      @lone_rook_board[:a1].should be_nil
      @lone_rook_board[:a8].should == @rook
    end
    
    @lone_rook_board[:a1].should == @rook
  end
  
  it 'can capture a piece on board by moving onto its square' do
    @kings_and_queens.move!( Move.new( :from_coord => :d8, :to_coord => :d1) )  #daring Queen capture
    @kings_and_queens.squares_occupied.length.should == 3
    @kings_and_queens[:d1].side.should == :black
  end

  it 'can undo a capture when only considering it as a move' do
    @kings_and_queens= Board[ :d1 => @white_queen, :e1 => @white_king, :d8 => @black_queen, :e8 => @black_king ]
    @kings_and_queens.consider_move( Move.new( :from_coord => :d8, :to_coord => :d1 ) )  do
      @kings_and_queens.squares_occupied.length.should == 3
      @kings_and_queens[:d1].side.should == :black
    end
    @kings_and_queens.squares_occupied.length.should == 4
    @kings_and_queens[:d1].side.should == :white
        
  end
  
  it 'should have 32 pieces on it initially' do
    @initial_board.pieces.length.should == 32
  end
  
  it 'should start with the white king on e1' do
     @initial_board[:e1].role.should == :king
    @initial_board[:e1].side.should == :white
  end

  it 'should start with the white king on d1' do
    @initial_board[:d1].role.should == :queen
    @initial_board[:d1].side.should == :white
  end
  
  it 'should start with the black king on e8' do
    @initial_board[:e8].role.should == :king
    @initial_board[:e8].side.should == :black
  end
  
  it 'king has no allowed moves on the initial board' do
    white_king = @initial_board[:e1]
    @initial_board.allowed_moves(:e1).length.should == 0
  end
  
  it 'knight has two moves on the initial board' do
    k = @initial_board[:b8]
    moves = @initial_board.allowed_moves(:b8)
    moves.length.should == 2
  end
  
  it 'pawn may move two squares on initial board' do
    p = @initial_board[:c7]
    moves = @initial_board.allowed_moves(:c7)
    moves.length.should == 2
  end
  
  it 'piece can capture by landing on opposing square' do
    board = Board[ :c6 => Piece.new(:knight, :black, :kings), :d4 => Piece.new(:pawn, :white, :d) ]
    
    moves = board.allowed_moves(:c6)
    moves.include?(:d4).should be_true
    board.move!( Move.new( :from_coord => :c6, :to_coord => :d4 ) )
    board[:d4].role.should == :knight
  end
  
  it 'pawn may move diagonally only if capturing' do
    board = Board[ :d4 => Piece.new(:pawn, :white, :d), :e5 => Piece.new(:pawn, :black, :e) ]
    moves = board.allowed_moves(:d4)
    moves.include?(:e5).should be_true
    board.move!( Move.new( :from_coord => :d4, :to_coord => :e5) )  
    board[:e5].side.should == :white
    
    #now there is not another piece to capture - he should only have one move
    board.allowed_moves(:e5).length.should == 1
  end

  it 'if capture coordinate included that piece will be deleted upon replay' do
    board = Board[ :d5 => Piece.new(:pawn, :white, :d), :c5 => Piece.new(:pawn, :black, :c) ]
    board.move!( Move.new( :from_coord => :d5, :to_coord => :c6, :capture_coord => :e5) )  
    assert_nil board[:e5]
  end

  it 'pawn can capture en passant' do
    #TODO technically if the pawn being captured has not been moved exactly once this should be forbidden but im ignoring that for now since it requires knowledge of the move list-  ditto for castling as well
    board = Board[ :d5 => Piece.new(:pawn, :white, :d), :c5 => Piece.new(:pawn, :black, :c) ]
    moves = board.allowed_moves(:d5)
     moves.include?(:c6).should_not be_true
  end
  
end
