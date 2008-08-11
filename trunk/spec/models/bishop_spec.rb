require File.dirname(__FILE__) + '/../spec_helper'

describe 'Bishop' do
  before(:all) do
    @white_bishop = Bishop.new(:white, :queens)
  end

  it 'should be able to move an unlimited number of squares along a diagonal' do
    moves = @white_bishop.desired_moves_from(:d4).map{ |vector| (Position.new(:d4) + vector).to_sym }
    moves.length.should==13
    [:c3, :c5, :e3, :e5].each do |square|
      moves.include?(square).should be_true
    end
  end
end
