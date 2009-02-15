require File.dirname(__FILE__) + '/../spec_helper'

describe Match, "A match" do

  def test_32_pieces_on_chess_initial_board
    assert_equal 32, matches(:unstarted_match).board.pieces.length
  end

  def test_first_player_to_move_is_player1
    m1 = matches(:unstarted_match)
    assert_equal 0, m1.moves.length
    assert m1.turn_of?( m1.player1)
  end

  #tests related to game play
  def test_next_to_move_alternates_sides
    m1 = matches(:unstarted_match)
    assert_equal 0, m1.moves.count
    assert m1.turn_of?( m1.player1 )
    
    m1.moves << Move.new(:from_coord=>'b2', :to_coord=>'b4' )
    
    assert m1.turn_of?( m1.player2 )

  end
      
  def test_knows_what_side_player_is_on
    m1 = matches(:paul_vs_dean)
    assert_equal players(:paul).id, m1.player1.id
    assert_equal players(:dean).id, m1.player2.id
    
    assert_equal :white, m1.side_of( players(:paul) )
    assert_equal :black, m1.side_of( players(:dean) )
    assert_equal :white, m1.opposite_side_of( players(:dean) )		
  end

  def test_knows_whose_turn_it_is
    m1 = matches(:paul_vs_dean)
    assert_equal 0, m1.moves.count

    assert m1.turn_of?( players(:paul) )
  end

  def test_shows_lineup
    assert_equal 'Paul vs. Dean', matches(:paul_vs_dean).lineup
    assert_equal 'Dean vs. Paul', matches(:dean_vs_paul).lineup
  end

  def test_player_can_resign
    #player1
    m1 = matches(:paul_vs_dean)
    m1.resign( players(:paul) )
    assert_not_nil m1.winning_player
    assert_equal players(:dean), m1.winning_player
  end

  describe "- with FEN changes - " do

    AFTER_E4 = 'RNBQKBNR/PPPP1PPP/4P3/8/8/8/pppppppp/rnbqkbnr b'

    it 'should have next_to_move black if FEN starts black (and even # of moves)' do
      m = Match.new( :start_pos => AFTER_E4 )
      m.next_to_move.should == :black
    end

    it 'should have newly retrieved matches current with FEN' do
      m = matches(:e4)
      m.next_to_move.should == :black
    end

    it 'should have next_to_move white if FEN starts black (and odd # of moves)' do
      m = matches(:e4)
      m.next_to_move.should == :black
      m.turn_of?( m.player2 ).should be_true

      m.moves << newm = Move.new( :from_coord => 'e7', :to_coord => 'e5' )
      m.next_to_move.should == :white
      m.turn_of?( m.player1 ).should be_true
    end

    it 'should reflect the piece location FEN indicates, not the initial board' do
      m = matches(:e4)
      m.board['e2'].should be_nil
      m.board['e4'].should_not be_nil
    end
  end

end
  
