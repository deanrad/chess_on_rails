require 'spec/spec_helper'

describe 'King' do
  before(:all) do
    @all_castlable = Board.new.delete_if{|k,v| [1,8].include?(k.rank) && !["a","e","h"].include?(k.file) }
  end

  it 'should be movable to castling squares (subject to board permitting it)' do
    k = @all_castlable[:e1]

    @all_castlable.white_kingside_castle_available.should == true
    k.allowed_moves(@all_castlable).should include(:g1)

    @all_castlable.white_queenside_castle_available.should == true
    k.allowed_moves(@all_castlable).should include(:c1)
  end
end
