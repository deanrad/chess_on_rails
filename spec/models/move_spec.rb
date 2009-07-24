require File.dirname(__FILE__) + '/../spec_helper'

describe Move do
    
  it 'should notate a noncapturing knight move' do
    match = matches(:unstarted_match)
    match.moves << Move.new( :from_coord => 'b1', :to_coord => 'c3' ) 
    assert_equal 'Nc3', match.moves.last.notation
  end
  
  it 'should notate noncapturing pawn move' do
    match = matches(:unstarted_match)
    match.moves << Move.new( :from_coord => 'd2', :to_coord => 'd4' ) #queens pawn
    assert_equal 'd4', match.moves.last.notation
  
    match.moves << Move.new( :from_coord => 'e7', :to_coord => 'e5' ) 
    assert_equal 'e5', match.moves.last.notation

    match.moves << Move.new( :from_coord => 'd4', :to_coord => 'e5' ) 
    assert_equal 'dxe5', match.moves.last.notation
  end

  it 'should notate white kingside castle' do
    match = matches(:dean_vs_maria)
    match.moves << Move.new( :from_coord => 'e1', :to_coord => 'g1' ) 

    #assert_equal 1, match.moves.last.castled
    assert_equal 'O-O', match.moves.last.notation

  end

  it 'should notate white queenside castle' do
    match = matches(:queenside_castled)
    match.moves << Move.new( :from_coord => 'e1', :to_coord => 'c1' ) 
    assert_equal 1, match.moves.last.castled
    assert_equal 'O-O-O', match.moves.last.notation
  end

  it 'should notate check if no intervening piece blocks check' do
    match = matches(:dean_vs_paul)
    match.moves << Move.new( :from_coord => 'f8', :to_coord => 'b4' ) 
    assert_equal 'Bb4+', match.moves.last.notation
  end

  it 'should not notate check if an intervening piece blocks check' do
    match = matches(:dean_vs_paul)
    match.moves << Move.new( :from_coord => 'f1', :to_coord => 'b5' ) 
    assert_equal 'Bb5', match.moves.last.notation
  end
  
  it 'should allow move from notation only' do
    match = matches(:dean_vs_paul)
    match.moves << Move.new( :notation => 'Bb5' )

    assert_equal 'f1', match.moves.last.from_coord
    assert_equal 'b5', match.moves.last.to_coord
  end

  it 'should allow move from notation only for pawn' do
    match = matches(:dean_vs_paul)
    match.moves << Move.new( :notation => 'a4' )

    assert_equal 'a2', match.moves.last.from_coord
    assert_equal 'a4', match.moves.last.to_coord
  end

  it 'should err for a move with incorrect notation' do
    match = matches(:dean_vs_paul)

    #models can raise errors, controllers ultimately should not
    assert_raises ActiveRecord::RecordInvalid do
      match.moves << Move.new( :notation => 'Bb3' )
    end
  end

  it 'should detect an illegal move' do
    match = matches(:unstarted_match)
    m = nil
    assert_raises ActiveRecord::RecordInvalid do
      match.moves << m = Move.new( :from_coord => 'b1', :to_coord => 'd1' ) #Nd1 ??
      # match.moves << m = Move.new( :from_coord => 'b3', :to_coord => 'b4' ) # ??
    end
  end
  
  it 'should notate which knight moved if ambiguous' do
    match = matches(:queenside_castled)

    #there are two knights which could have moved here - did we show which one
    match.moves << Move.new( :from_coord => 'g1', :to_coord => 'f3' )
    assert_equal 'Ngf3', match.moves.last.notation
  end

  it 'should notate knight move unambiguously' do
    match = matches(:queenside_castled)
    match.moves << move = Move.new( :notation => 'Ngf3' )
    match.moves.last.from_coord.should == 'g1'
  end

  it 'should allow castle via notation' do
    match = matches(:dean_vs_maria)
    move = match.moves << Move.new( :notation => 'O-O' )
    assert_equal 1, match.moves.last.castled
    assert_equal 'g1', match.moves.last.to_coord
  end

  it 'should err if unrecognized notation' do
    match = matches(:dean_vs_maria)
    assert_raises ActiveRecord::RecordInvalid do
      match.moves << move =  Move.new( :notation => 'move it baby' )
    end
  end
  
  it 'should err if notation is ambiguous' do
    match = matches(:queenside_castled)
    assert_raises ActiveRecord::RecordInvalid do
      match.moves << move = Move.new( :notation => 'Nf3' )
    end
    #move.should_not be_valid
  end

  it 'should disallow combined notation and coordinate move' do
    match = matches(:unstarted_match)
    lambda{
      m = Move.new( :notation => 'e4', :from_coord => 'e2', :to_coord => 'e4' )
    }.should raise_error

  end

  it 'should be an error to leave ones king in check' do
    match = matches(:scholars_mate)
    
    #this is not a mating move but king is in check and must move
    match.moves << move = Move.new( :notation => 'Bxf7' )
    
    assert_raises ActiveRecord::RecordInvalid do
      match.moves << move = Move.new( :notation => 'Nf6' )
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
    m.match.gameplays.white.move_queue.to_s.should == 'e5 d4'
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

    match.gameplays.white.move_queue.should be_blank
  end

  it 'should invalidate the move queue if an invalid prediction was made' do
    match = matches(:unstarted_match)
    match.moves << m = Move.new( :notation => 'e4 e5 d4 Nc3 Nc6' )
    match.moves << m = Move.new( :notation => 'd5' )
    match.gameplays.white.move_queue.should be_blank
  end

end
