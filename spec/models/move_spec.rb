require 'spec/spec_helper'

describe Move do
  before(:each) do 
    @match = matches(:unstarted_match) #overridable
  end
  attr_accessor :match
  
  describe 'Capturing' do
    it 'should populate the captured_piece coordinate' do
      match = matches(:ready_to_capture)
      match.moves << move = Move.new(:from_coord => 'e4', :to_coord => 'd5')

      move.captured_piece_coord.should == 'd5'
      move.notation.should == 'exd5'
    end
  end

  describe 'Validation' do
    it 'should disallow a move with nonsensical coordinates' do
      match.moves << move = Move.new(:from_coord => '4d', :to_coord => 'd4')
      move.errors_on(:from_coord).should include( t('errors.from_coord_must_be_valid', move ) )
    end
  end
end
