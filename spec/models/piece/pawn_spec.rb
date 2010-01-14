require 'spec/spec_helper'

describe 'Piece Movement' do
  describe 'Pawn' do
    before(:all) do
      @initial = Board.new
      @pawn_single = @initial.consider_move( Move.new(:from_coord => "d2", :to_coord => "d3") )
    end

    it 'should be able to move (only) one or two from its starting rank' do
      p = @initial[:d2]
      p.allowed_moves(@initial).to_set.should == [:d3, :d4].to_set
    end

    it 'should be only able to advance one once moved' do
      p = @pawn_single[:d3]
      p.allowed_moves(@pawn_single).to_set.should == [:d4].to_set
    end

  end
end
