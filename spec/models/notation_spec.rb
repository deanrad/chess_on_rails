require File.dirname(__FILE__) + '/../spec_helper'

describe 'Notation - ' do
  before(:all) do
    @initial_board = Board.initial_board    

    @white_king, @white_queen = [ Piece.new(:king, :white), Piece.new(:queen, :white) ]
    @black_king, @black_queen = [ Piece.new(:king, :black), Piece.new(:queen, :black) ]
    @kings_and_queens= Board[ :d1 => @white_queen, :e1 => @white_king, :d8 => @black_queen, :e8 => @black_king ]

    @promotable = Board[:d7 => Pawn.new(:white, :d)]

    @initial_knight_move  = Notation.new( 'Nc3', @initial_board )
    @initial_knight_move_by_coords  = Notation.new( :b1, :c3, @initial_board )
    @promotable = Board[:d7 => Pawn.new(:white, :d)]
    @capturable = Board[:b2 => Bishop.new(:white, :queens), :h8 => Rook.new(:black, :kings) ]
    @castling_board = Board[:a1 => Rook.new(:white, :queens), :e1 => King.new(:white), :h1 => Rook.new(:white, :kings)]

    
    @two_knights_may_move_to_d5_diff_files = Board[ :c3 => Knight.new(:white, :kings), :f4 => Knight.new(:white, :queens) ]
    @two_knights_may_move_to_d5_same_files = Board[ :c3 => Knight.new(:white, :kings), :c7 => Knight.new(:white, :queens) ]
  end

  describe 'Constructors' do
    it 'should be creatable given a from and to coordinate pair, and a board' do
      n  = Notation.new( :b1, :c3, @initial_board )
      n.board.should == @initial_board
    end
    it 'should be creatable given a notation and a board' do
      n  = Notation.new( 'Nc3', @initial_board )
      n.board.should == @initial_board
    end
  end

  describe 'Functions' do
    it 'should be able to map piece types to abbreviations' do
      Notation.abbrev(:knight).should == 'N'
      Notation.abbrev(:bishop).should == 'B'
      #etc..
    end
    it 'should be able to map abbreviations to piece types' do
      Notation.role_of('B').should == :bishop
      Notation.role_of('N').should == :knight
    end
  end
  
  describe 'Data Fields' do
    it 'should encode for the role of the piece that is moving' do
      @initial_knight_move.role = :knight
      @initial_knight_move.role.should == :knight
    end
    it 'should encode for whether a capture occcurred' do
      @initial_knight_move.capture = true
      @initial_knight_move.capture.should == true
    end

    it 'should encode for the destination square' do
      @initial_knight_move.to_coord = :c4
      @initial_knight_move.to_coord.should == :c4
    end

    it 'should encode for which promotion choice was made' do
      @initial_knight_move.promotion_choice = :queen
      @initial_knight_move.promotion_choice.should == :queen
    end

    it 'should reflect whether check occurred on that move' do
      @initial_knight_move.check = true
      @initial_knight_move.check.should == true
    end

    it 'should reflect whether checkmate occurred on that move' do
      @initial_knight_move.checkmate = true
      @initial_knight_move.checkmate.should == true
    end

  end
  
  describe 'Serialization' do
    it 'should store the piece abbreviation in the first character for non-pawns' do
      @initial_knight_move_by_coords.to_s[0,1].should == 'N'
    end

    it 'should have an optional x in the next position if the capture field is true' do
      n = Notation.new(:d1, :d8, @kings_and_queens)
      ns = n.to_s
      ns[0,1].should == 'Q'
      ns[1,1].should == 'x'
    end

    it 'should have a complete to coordinate present only after previous fields' do
      pawn_move_notation = Notation.new(:d2, :d4, @initial_board)
      queen_capture_notation = Notation.new(:d1, :d8, @kings_and_queens)

      #role-omitted pawn move
      pawn_move_notation.to_s[0,2].should == 'd4'
      
      #normal noncapture      
      @initial_knight_move_by_coords.to_s[1,2].should == 'c3'
      
      #normal capture
      queen_capture_notation.to_s[2,2].should == 'd8'
    end

    it 'should have = followed by a piece type abbreviation if promotion occurred' do
      n = Notation.new(:d7, :d8, @promotable)
      n.to_s.should == 'd8=Q'
    end
    
    it 'should have a + following the to coordinate if check occurred but not checkmate' do
      n = Notation.new(:d1, :d8, @kings_and_queens)
      n.check = true
      n.to_s[4,1].should == '+'
    end
    
    it 'should have a # following the to coordinate if checkmate occurred' do
      board = Board[:d1 => Rook.new(:white, :kings), :d2 => Queen.new(:white), :d8 => King.new(:black) ]
      n = Notation.new(:d2, :d7, board)
      n.checkmate = true    #must be set by caller
      n.to_s[3,1].should == '#'
    end
  end

  describe 'Piece disambiguation' do
    it 'should be necessary if more than one of a piece type could have moved to the to coordinate' do
      board = @two_knights_may_move_to_d5_diff_files
      n = Notation.new( :c3, :d5, board )
      n.to_s.should == 'Ncd5'
    end
    
    it 'should preferentially be the file that differentiates between the pieces if it does so' do
      board = @two_knights_may_move_to_d5_diff_files
      n = Notation.new( :f4, :d5, board )
      #these are also on different ranks, but f is the disambiguator
      #n.disambiguator.should == 'f'
      n.to_s.should == 'Nfd5'
    end

    it 'should secondarily be the rank that differentiates between the pieces' do
      board = @two_knights_may_move_to_d5_same_files
      n = Notation.new( :c7, :d5, board )
      n.to_s.should == 'N7d5'
    end
  end
  
  describe 'Castling' do
    it 'should reflect kingside castle with O-O' do
      board = @castling_board
      n = Notation.new( :e1, :g1, board )
      n.to_s.should == 'O-O'
    end
    it 'should reflect queenside castle with O-O-O' do
      board = @castling_board
      n = Notation.new( :e1, :c1, board )
      n.to_s.should == 'O-O-O'
    end
  end
  
  describe 'Coordinates to Notation' do
    it 'should have an X in the 2nd character position if capturing' do
      n = Notation.new(:b2, :h8, @capturable)
      n.to_s[1,1].should == 'x'
    end
  end

  describe 'Notation to Coordinates' do
    it 'should parse Nc3 as b1 to c3' do
      board = @initial_board
      n = Notation.new( "Nc3", board )
      n.to_coords.should == [:b1, :c3]
    end
    
    it 'should parse O-O as e1 to g1 with white next to move' do 
      board = @castling_board
      n = Notation.new( "O-O", board )
      n.next_to_move = :white
      n.to_coords.should == [:e1, :g1]
    end
    
    it 'should parse O-O as e8 to g8 with black next to move' do 
      board = @castling_board
      n = Notation.new( "O-O", board )
      n.next_to_move = :black
      n.to_coords.should == [:e8, :g8]
    end

    it 'should parse O-O-O as e1 to c1 with white next to move' do 
      board = @castling_board
      n = Notation.new( "O-O-O", board )
      n.next_to_move = :white
      n.to_coords.should == [:e1, :c1]
    end

    it 'should parse O-O-O as e8 to c8 with black next to move' do 
      board = @castling_board
      n = Notation.new( "O-O-O", board )
      n.next_to_move = :black
      n.to_coords.should == [:e8, :c8]
    end
    
    it 'should raise an error if more than one of that piece type could move to that destination square' do
      board = @two_knights_may_move_to_d5_diff_files
      n = Notation.new( "Nd5", board )
      lambda{ c = n.to_coords }.should raise_error
    end
    
    it 'should use a piece disambiguator if needed' do
      board = @two_knights_may_move_to_d5_diff_files
      n = Notation.new( "Ncd5", board )
      n.to_coords.should == [:c3, :d5]
    end

    it 'should raise an Exception if a from and to coordinate pair cannot be found' do
      board = @castling_board
      n = Notation.new( "Ke4", board) #cant move there
      lambda{ c = n.to_coords }.should raise_error
    end
  end   
  
end
