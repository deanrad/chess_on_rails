require File.dirname(__FILE__) + '/../spec_helper'

describe Move do
    
  it 'should notate a noncapturing knight move' do
    match = matches(:unstarted_match)
    match.moves << Move.new( :from_coord => 'b1', :to_coord => 'c3' ) 
    assert_equal 'Nc3', match.moves.last.notation
  end
  
  it 'should notates_noncapturing_pawn_moves_correctly' do
    match = matches(:unstarted_match)
    match.moves << Move.new( :from_coord => 'd2', :to_coord => 'd4' ) #queens pawn
    assert_equal 'd4', match.moves.last.notation
  
    match.moves << Move.new( :from_coord => 'e7', :to_coord => 'e5' ) 
    assert_equal 'e5', match.moves.last.notation

    match.moves << Move.new( :from_coord => 'd4', :to_coord => 'e5' ) 
    assert_equal 'dxe5', match.moves.last.notation
  end

  it 'should notates_white_kingside_castle_correctly' do
    match = matches(:dean_vs_maria)
    match.moves << Move.new( :from_coord => 'e1', :to_coord => 'g1' ) 

    assert_equal 1, match.moves.last.castled
    assert_equal 'O-O', match.moves.last.notation

  end

  it 'should notates_white_queenside_castle_correctly' do
    match = matches(:queenside_castled)
    match.moves << Move.new( :from_coord => 'e1', :to_coord => 'c1' ) 
    assert_equal 1, match.moves.last.castled
    assert_equal 'O-O-O', match.moves.last.notation
  end

  it 'should notates_check_if_no_intervening_piece_blocks_check' do
    match = matches(:dean_vs_paul)
    match.moves << Move.new( :from_coord => 'f8', :to_coord => 'b4' ) 
    assert_equal 'Bb4+', match.moves.last.notation
  end

  it 'should not_notate_check_if_intervening_piece_blocks_check' do
    match = matches(:dean_vs_paul)
    match.moves << Move.new( :from_coord => 'f1', :to_coord => 'b5' ) 
    assert_equal 'Bb5', match.moves.last.notation
  end
  
  it 'should allow_move_from_notation_only' do
    match = matches(:dean_vs_paul)
    match.moves << Move.new( :notation => 'Bb5' )

    assert_equal 'f1', match.moves.last.from_coord
    assert_equal 'b5', match.moves.last.to_coord
  end

  it 'should allow_move_from_notation_only_pawn_version' do
    match = matches(:dean_vs_paul)
    match.moves << Move.new( :notation => 'a4' )

    assert_equal 'a2', match.moves.last.from_coord
    assert_equal 'a4', match.moves.last.to_coord
  end

  it 'should detect_attempt_to_move_from_incorrect_notation' do
    match = matches(:dean_vs_paul)

    #models can raise errors, controllers ultimately should not
    assert_raises ActiveRecord::RecordInvalid do
      match.moves << Move.new( :notation => 'Bb3' )
    end
  end
  
  it 'should notate_which_knight_moved_to_a_square_if_ambiguous' do
    match = matches(:queenside_castled)

    #there are two knights which could have moved here - did we show which one
    match.moves << Move.new( :from_coord => 'g1', :to_coord => 'f3' )
    assert_equal 'Ngf3', match.moves.last.notation
  end

  it 'should disambiguate_knight_move_in_coordinates_when_moved_by_notation' do
    pending do
      match = matches(:queenside_castled)
    
      move = match.moves.build( :notation => 'Ngf3' )
      move.save!
      assert_equal 'g1', match.moves.last.from_coord
    end
  end

  it 'should allow castle_via_notation' do
    match = matches(:dean_vs_maria)
    move = match.moves << Move.new( :notation => 'O-O' )
    assert_equal 1, match.moves.last.castled
    assert_equal 'g1', match.moves.last.to_coord
  end

  it 'should err if_unrecognized_notation' do
    match = matches(:dean_vs_maria)
    assert_raises ActiveRecord::RecordInvalid do
      match.moves << move =  Move.new( :notation => 'move it baby' )
    end
  end
  
  it 'should err_if_ambiguous_move_made_by_notation' do

    match = matches(:queenside_castled)
    assert_raises ActiveRecord::RecordInvalid do
      match.moves << move = Move.new( :notation => 'Nf3' )
    end
  end

  it 'should disallow combined notation and coordinate move' do
    match = matches(:unstarted_match)
    lambda{
      m = Move.new( :notation => 'e4', :from_coord => 'e2', :to_coord => 'e4' )
    }.should raise_error

  end

  it 'should be an error to leave ones king in check' do
    pending do
      match = matches(:scholars_mate)

      #this is not a mating move but king is in check and must move
      match.moves << Move.new( :notation => 'Bxf7' )
      
      assert_raises ActiveRecord::RecordInvalid do
        move = match.moves.build( :notation => 'Nf6' )
        move.save!
      end
    end
  end

  it 'should strip off the move queue part of any notated move' do
    match = matches(:unstarted_match)
    match.moves << m = Move.new( :notation => 'e4 e5 d4' )
    m.notation.should == 'e4'
  end

  it 'should store the move queue part of any notated move' do
    match = matches(:unstarted_match)
    match.moves << m = Move.new( :notation => 'e4 e5 d4' )
    m.match.gameplays.white.first.move_queue.to_s.should == 'e5 d4'
  end

  it 'should play the next move in the move queue if the notation matches' do
    match = matches(:unstarted_match)
    match.moves << m = Move.new( :notation => 'e4 e5 d4 Nc6 Nc3' )
    match.moves << m = Move.new( :notation => 'e5' )

    match.reload
    match.moves.count.should == 3
    match.moves.reload.last.notation.should == 'd4'
  end

  it 'should keep playing from each move queue in turn' do
    match = matches(:unstarted_match)
    match.moves << m = Move.new( :notation => 'e4 e5 d4 Nc6 Nc3' )
    match.moves << m = Move.new( :notation => 'e5 d4 Nc6' )

    match.reload ; match.moves.reload
    match.moves[1].notation.should == 'e5'
    match.moves[2].notation.should == 'd4'
    match.moves[3].notation.should == 'Nc6'
    match.moves[4].notation.should == 'Nc3'

    match.gameplays.white.first.move_queue.should be_blank
  end

  it 'should invalidate the move queue if an invalid prediction was made' do
    match = matches(:unstarted_match)
    match.moves << m = Move.new( :notation => 'e4 e5 d4 Nc3 Nc6' )
    match.moves << m = Move.new( :notation => 'd5' )
    match.gameplays.white.first.move_queue.should be_blank
  end
  
  #it 'should play the next two moves in the move queue if the notation differs but indicates same move'

end
