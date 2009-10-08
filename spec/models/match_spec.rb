require File.dirname(__FILE__) + '/../spec_helper'

describe Match do
  include PgnFixtures

  it 'should have player1 be the first to move' do
    m1 = matches(:unstarted_match)

    m1.turn_of?(m1.player1).should be_true
  end

  it 'should be player2 the next to move' do
    m1 = matches(:unstarted_match)
    m1.moves << Move.new(:from_coord => 'b2', :to_coord => 'b4' )
    
    m1.turn_of?(m1.player2).should be_true
  end

  it 'should know current player via next to move' do
    m1 = matches(:paul_vs_dean)
    m1.next_to_move.should == :white
    m1.current_player.should == players(:paul)
  end
      
  it 'should label player1 as white and player2 as black' do
    m1 = matches(:paul_vs_dean)
    
    m1.side_of( players(:paul) ).should == :white
    m1.side_of( players(:dean) ).should == :black
  end

  it 'should display the lineup as player1 vs. player 2' do
    matches(:paul_vs_dean).lineup.should == 'Paul vs. Dean'
    matches(:dean_vs_paul).lineup.should == 'Dean vs. Paul'
  end

  it 'should be creatable with one player as white and another as black' do
    m = Match.new( :white => players(:maria), :black => players(:paul) )
    m.player2.should == players(:paul)
  end

  it 'should have a name' do
    m = matches(:immortal)
    m.name.should == "The Immortal Match (Anderssen vs. Kieseritzky, 1851)"
  end

  it 'should have a board' do
    m = matches(:queenside_castled)
    m.board.should_not be_nil
    m.boards.size.should == 9 
  end

  describe 'resignation' do

    it 'should make a match inactive' do
      m1 = matches(:paul_vs_dean)
      m1.resign( players(:paul) )
      m1.should_not be_active
    end

    it 'should make the other guy the winner' do
      m1 = matches(:paul_vs_dean)
      m1.resign( players(:paul) )
      m1.winning_player.should == players(:dean)
    end

  end

  describe "- with FEN changes - " do

    AFTER_E4 = 'RNBQKBNR/PPPP1PPP/4P3/8/8/8/pppppppp/rnbqkbnr b'

    it 'should have next_to_move black if FEN starts black (and even # of moves)' do
      m = Match.new( :start_pos => AFTER_E4, :white => players(:dean), :black => players(:paul) )
      m.next_to_move.should == :black
    end

    it 'should have newly retrieved matches current with FEN' do
      m = matches(:e4)
      m.next_to_move.should == :black
    end

    it 'should have next_to_move white if FEN starts black (and odd # of moves)' do
      pending 'it blows up'

      m = matches(:e4)
      m.next_to_move.should == :black
      m.turn_of?( m.player2 ).should be_true

      m.moves << move = Move.new( :from_coord => 'e7', :to_coord => 'e5' )
      m.next_to_move.should == :white
      m.turn_of?( m.player1 ).should be_true
    end

    it 'should reflect the piece location FEN indicates, not the initial board' do
      m = matches(:e4)
      m.board[:e2].should be_nil
      m.board[:e4].should_not be_nil
    end
  end

  it 'should instantiate a pgn fixture' do
    m = matches(:pgn_playback_problem)
    m.moves.length.should == 23
    m.moves.first.notation.should == 'd4'
    m.moves.last.notation.should == 'O-O'
  end
end
  
