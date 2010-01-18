require 'spec/spec_helper'

describe Move do
  before(:each) do 
    @match = matches(:unstarted_match) #overridable
  end
  attr_accessor :match
  
  describe 'Capturing' do
    it 'should populate the captured_piece coordinate field upon save' do
      match = matches(:ready_to_capture)
      match.moves << move = Move.new(:from_coord => 'e4', :to_coord => 'd5')

      move.captured_piece_coord.should == 'd5'
      move.notation.should == 'exd5'
    end
  end

  describe 'Castling' do
    it 'should populate the castling_rook_from coordinate field upon save' do
      match = matches(:castled)
      Move.delete(match.moves.last.id) # uncastle
      
      match.moves << move = Move.new(:from_coord => 'e1', :to_coord => 'g1')

      move.castled?.should == true
      move.castling_rook_from_coord.should == 'h1'
      move.castling_rook_to_coord.should == 'f1'
    end
  end

  describe 'Validation' do
    it 'should disallow a move with nonsensical coordinates' do
      match.moves << move = Move.new(:from_coord => '4d', :to_coord => 'd4')
      move.errors_on(:from_coord).should include( t('errors.from_coord_must_be_valid', move ) )
    end
  end
end
