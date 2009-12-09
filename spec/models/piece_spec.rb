require 'spec/spec_helper'

describe Piece do

  # TODO Piece specs

  describe 'Point Values' do
    it 'Queen should be valued at 9' do
      Queen.new(:white).point_value.should == 9
    end
    it 'Rook should be valued at 5' do
      Rook.new(:white).point_value.should == 5
    end
    it 'Bishop and Knight should be valued at 3' do
      Bishop.new(:white).point_value.should == 3
      Knight.new(:white).point_value.should == 3
    end
    it 'Pawn should be valued at 1' do
      Pawn.new(:white).point_value.should == 1
    end
  end
end
