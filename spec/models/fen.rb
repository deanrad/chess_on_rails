require File.dirname(__FILE__) + '/../spec_helper'

describe 'Forsyth-Edwards (FEN) Notation' do

  describe '- in general' do
    it 'should be a module extending Board'

    it 'should allow a board to be created from a Fen string' 

    it 'should allow a board to be serialized as a Fen string'
  end
  
  describe '- section layout' do

    it 'should have at least three fields separated by whitespace'

    it 'should have nothing but piece characters and digits 1-8 and slash in first field'

    it 'should have a single w or b in the second field for who\'s next to move'

    it 'should have a dash, or some combination of k and q in the third field'
 
    it 'should optionally have an en passant capture square in the fourth field'

    describe '- a section one layout instruction' do
      it 'should correspond to square a1 initially'

      it 'should lay out a piece if rnbqkp'

      it 'should lay out a black piece if lower case'
   
      it 'should lay out a white piece if upper case'
 
      it 'should lay out a space if a digit 1-8'

      it 'should increment by one if a piece was laid out'

      it 'should increment by the number if a number was used'
  
      it 'should increment to the next file once 8 has been reached'
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
    it 'should regonize RNBQKBNR/PPPPPPPP/8/8/8/8/pppppppp/rnbqkbnr as the initial board'

  end

end
