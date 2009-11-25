require 'spec/spec_helper'

describe Move do
  before(:each) do 
    @match = matches(:unstarted_match) #overridable
  end
  attr_accessor :match
  
  describe 'Validation' do
    it 'should disallow a move with nonsensical coordinates' do
      begin
        match.moves << move = Move.new(:from_coord => '4d', :to_coord => 'd4')
        # currently the board kicks out the move 
      rescue Board::MoveInvalid => ex
        ex.message.to_s.should == "From coord " + t( :err_from_coord_must_be_valid, move )
      end
    end
  end
end
