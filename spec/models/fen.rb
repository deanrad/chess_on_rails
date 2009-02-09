require 'ruby-debug'
require File.dirname(__FILE__) + '/../spec_helper'

describe 'Forsyth-Edwards (FEN) Notation' do

  INITIAL_BOARD = 'RNBQKBNR/PPPPPPPP/8/8/8/8/pppppppp/rnbqkbnr'
  ROOK_A1_ONLY = 'R7/8/8/8/8/8/8/8'
  KQ_ONLY = '3KQ3/8/8/8/8/8/8/3kq3'

  describe '- in general' do
    it 'should be a module extending Board' do
      b = Board.new
      b.extended_by.should include(Fen)
    end

    it 'should allow a board to be created from a Fen string' do
      b = Board.new( INITIAL_BOARD )
      b.should_not be_nil
      b.pieces.should have(32).pieces
    end

    it 'should allow a board to be serialized as a Fen string' do
      b = Board.new( Match.new, Chess.initial_pieces )
      b.to_fen.should include( INITIAL_BOARD )
    end 
  end
  
  describe '- section layout' do

    it 'should have at least three fields separated by whitespace'

    it 'should have nothing but piece characters and digits 1-8 and slash in first field'

    it 'should have a single w or b in the second field for the side next to move'

    it 'should have a dash, or some combination of k and q in the third field'
 
    it 'should optionally have an en passant capture square in the fourth field'

    describe '- a section one layout instruction' do
      it 'should correspond to square a1 initially' do
        b = Board.new( ROOK_A1_ONLY )
        b["a1"].role.should == "rook"
      end

      it 'should lay out a piece if rnbqkp' do
        b = Board.new( ROOK_A1_ONLY )
        b.pieces.should have(1).piece
      end

      it 'should lay out a black piece if lower case' do
        b = Board.new( ROOK_A1_ONLY.downcase )
        b["a1"].side.should == :black
      end
   
      it 'should lay out a white piece if upper case' do
        b = Board.new( ROOK_A1_ONLY )
        b["a1"].side.should == :white
      end
 
      it 'should lay out a space if a digit 1-8' do
        b = Board.new( KQ_ONLY )
        b["a1"].should be_nil
      end

      it 'should increment by one if a piece was laid out' do
        b = Board.new( KQ_ONLY )
        b["d1"].should_not be_nil
        b["e1"].should_not be_nil
      end

      it 'should increment by the number if a number was used' do
        b = Board.new( KQ_ONLY )
        KQ_ONLY[0..0].should == "3"
        ( b["a1"] && b["b1"] && b["c1"] ).should be_nil

      end
  
      it 'should increment to the next rank once 8 has been reached' do
        b = Board.new( "8/P7/8/8/8/8/8/8" )
        b.pieces.should have(1).piece
        b.pieces[0].position.should == "a2"
      end
    end

    describe '- the next to move instruction' do
      it 'should leave white as the next to move if w or nothing in field 2'

      it 'should leave black as the next to move if b in field 2'
    end

  end

  describe '- is in error if' do
    it 'does not account for every square' 

    it 'over-allocates pieces to the board' 

    it 'does not place a king'

    it 'impossibly places a pawn'

    it 'places the player next to move in check'

    it 'does not indicate w or b in second field for the next player to move'

    it 'indicates an impossible en passant square'
  end  

  describe '- example boards' do
    it "should recognize #{INITIAL_BOARD} as the initial board" 

  end

end
