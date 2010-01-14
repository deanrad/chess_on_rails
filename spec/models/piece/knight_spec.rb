require 'spec/spec_helper'

describe 'Piece Movement' do
  describe 'Knight' do
    before(:all) do
      @initial = Board.new
    end

    it 'should be able to hop to in front of bishop or rook on first move' do
      k = @initial[:b1]
      k.allowed_moves(@initial).to_set.should == [:a3, :c3].to_set
    end

  end
end
