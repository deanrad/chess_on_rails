require File.dirname(__FILE__) + '/../spec_helper'

describe Board do
  
  before(:all) do
    @rook = Piece.new(:rook, :white )
    @white_king, @white_queen = [ Piece.new(:king, :white), Piece.new(:queen, :white) ]
    @black_king, @black_queen = [ Piece.new(:king, :black), Piece.new(:queen, :black) ]

    @lone_rook_board = Board[ :a1 => @rook ]
    @initial_board = Board.initial_board    
    @castling_board_king  = Board[ :e1 => King.new(:white), :h1 => Rook.new(:white, :kings) ]
    @castling_board_queen = Board[ :d8 => King.new(:black), :a8 => Rook.new(:black, :queens) ]
    
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

  it 'should be able to undo a considered move if castling' do
    
    @castling_board_king[:f1].should be_nil
    
    castling = Move.new( :from_coord => :e1, :to_coord => :g1, :castled => true) #must include castled=>true
    @castling_board_king.consider_move( castling ) do
      @castling_board_king[:f1].role.should == :rook
      @castling_board_king[:g1].role.should == :king
      @castling_board_king[:h1].should be_nil
    end
    
    @castling_board_king[:h1].role.should == :rook
    @castling_board_king[:e1].role.should == :king
    @castling_board_king[:f1].should be_nil
  end
  
  it 'should not allow a piece to move onto one of its own color, now matter how nicely it asks' do
    #king
    @initial_board.allowed_moves(:e1).should be_empty

    #knight
    @initial_board.allowed_moves(:g8).should == [:h6, :f6] #have(2).items 

  end
  
  it 'should not allow a piece to move past an occupied position' do 
    #queen
    @kings_and_queens.allowed_moves(:d1).should_not include(:h1) #blocked by king
  end
  
end
