require 'spec/spec_helper'

describe Board do
  before(:each) do
    @opposing_pawns = Board.new( :d4 => Pawn.new(:white), :e5 => Pawn.new(:black) )
    @initial_board = Board.new
    @castling_allowed = Board.new(
       :a1 => Rook.new(:white, :queens), :e1 => King.new(:white), :h1 => Rook.new(:white, :kings),
       :a8 => Rook.new(:black, :queens), :e8 => King.new(:black), :h8 => Rook.new(:black, :kings)
    )
  end

  it 'should allow moves by any party at any time (Match, not Board enforces this rule)' do
    lambda{
      @opposing_pawns.play_move!( move %w{ d4 d5 } )
    }.should_not raise_error
    lambda{
      @opposing_pawns.play_move!( move %w{ e5 e4 } )
    }.should_not raise_error
  end

  it 'should raise an error unless given from_coord and to_coord' do
    lambda{
      @opposing_pawns.play_move!( Move.new "d4" )
    }.should raise_error(Board::MissingCoord)
  end

  it 'should raise an error unless a piece is present on the from_coordinate' do
    lambda{
      @opposing_pawns.play_move!( move %w{ a2 a3 } )
    }.should raise_error(Board::PieceNotFound)
  end

  it 'should move a piece off the board (to the graveyard) when that piece is moved upon' do
    @opposing_pawns.deleted_pieces.count.should == 0
    @opposing_pawns.pieces.count.should == 2
    @opposing_pawns.play_move!( move %w{ d4 e5 } )
    @opposing_pawns.pieces.count.should == 1
    @opposing_pawns.deleted_pieces.count.should == 1
    # @opposing_pawns.graveyard.count.should == 1
  end


  it 'should remember which piece was last moved' do
    @opposing_pawns.play_move!( move %w{ d4 d5 } )
    @opposing_pawns.piece_last_moved.should == @opposing_pawns[:d5]
  end

  describe 'Playing Moves' do
    describe 'Castling Flags' do
      it 'should initially flag castling as available for any side/flank' do
        @castling_allowed.white_kingside_castle_available.should == true
        @castling_allowed.white_queenside_castle_available.should == true
        @castling_allowed.black_kingside_castle_available.should == true
        @castling_allowed.black_queenside_castle_available.should == true
      end

      it 'should flag kingside castling unavailable when the kingside rook is moved' do
        @castling_allowed.play_move!( move %w{ h8 h7 } )
        @castling_allowed.black_queenside_castle_available.should == true
        @castling_allowed.black_kingside_castle_available.should == false
      end

      it 'should flag kingside castling unavailable when the kingside rook is moved' do
        @castling_allowed.play_move!( move %w{ a1 a2 } )
        @castling_allowed.white_queenside_castle_available.should == false
        @castling_allowed.white_kingside_castle_available.should == true
      end

      it 'should flag both castlings unavailable when the king is moved' do
        @castling_allowed.play_move!( move %w{ e1 f2 } )
        @castling_allowed.white_queenside_castle_available.should == false
        @castling_allowed.white_kingside_castle_available.should == false
      end

    end
  end

  def move( *opts )
   case opts
   when Hash
     Move.new( opts )
   when Array
     Move.new( :from_coord => opts[0][0], :to_coord => opts[0][1] )
   when String
     Move.new( :notation => opts )
   end
  end
end
