require File.dirname(__FILE__) + '/../spec_helper'

describe Match do

  # Replace this with your real tests.
  it 'should have player 1 on white and player 2 on black' do
    match = matches(:dean_vs_maria)
    match.player1.should == players(:dean)
    match.white.should == players(:dean)
    match.black.should == players(:maria)
  end

  it 'can create match' do
    match = ::Match.new( :player1 => players(:dean), :player2 => players(:anders) )
    match.save!
    match.lineup.should == 'dean vs. anders'
  end
  
  it 'replays board to current position' do
    match = matches(:dean_vs_maria)
    board = match.board
    assert_nil board[:d2] #this is the piece that was moved
  end

end
