require File.dirname(__FILE__) + '/../spec_helper'

describe Move do
  it 'should detect an illegal move' do
    match = matches(:unstarted_match)
    m = nil
    match.moves << move = Move.new( :from_coord => 'b1', :to_coord => 'd1' )
    move.should_not be_valid
  end
  
  it 'should be an error to leave ones king in check' do
    match = matches(:scholars_mate)

    #this is not a mating move but king is in check and must move
    match.moves << move = Move.new( :notation => 'Bxf7' )
    
    match.moves << move = Move.new( :notation => 'Nf6' )
    move.should_not be_valid
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

  it 'should allow a wildcard character (*) in the queue' do
    match = matches(:unstarted_match)
    match.moves << m = Move.new( :notation => 'e4 * d4' )
    match.moves << m = Move.new( :notation => 'e5' )
    match.reload ; match.moves.reload

    match.moves.count.should == 3
  end

  it 'should invalidate the move queue if an invalid prediction was made' do
    match = matches(:unstarted_match)
    match.moves << m = Move.new( :notation => 'e4 e5 d4 Nc3 Nc6' )
    match.moves << m = Move.new( :notation => 'd5' )
    match.gameplays.white.move_queue.should be_blank
  end

  describe 'Notation' do
    it 'should notate king K' do
      King.new(:white).abbrev.upcase.should == 'K'
    end
    it 'should notate queen Q' do
      Queen.new(:white).abbrev.upcase.should == 'Q'
    end
    it 'should notate rook R' do
      Rook.new(:white).abbrev.upcase.should == 'R'
    end
    it 'should notate knight N' do
      Knight.new(:white).abbrev.upcase.should == 'N'
    end
    it 'should notate bishop B' do
      Bishop.new(:white).abbrev.upcase.should == 'B'
    end

    it 'should notate a pawn for the file it is on' do
      pending('havent found how to do this yet')
      p = Pawn.new(:black)
      p.notation('b').should == 'b'
      p.notation('c').should == 'c'
    end

    it 'should not notate a pawn without its file' do
      p = Pawn.new(:white)
      lambda{ p.notation.should == 'p' }.should raise_error
    end

    it 'should notate which knight moved if ambiguous' do
      match = matches(:queenside_castled)

      #there are two knights which could have moved here - did we show which one
      match.moves << move = Move.new( :from_coord => 'g1', :to_coord => 'f3' )
      move.notation.should == 'Ngf3'
    end

    it 'should notate knight move unambiguously' do
      match = matches(:queenside_castled)
      match.moves << move = Move.new( :notation => 'Ngf3' )
      move.from_coord.should == 'g1'
    end

    it 'should allow castle via notation' do
      match = matches(:dean_vs_maria)
      match.moves << move = Move.new( :notation => 'O-O' )
      move.castled.should == 1
      move.to_coord.should == 'g1'
    end

    it 'should err if unrecognized notation' do
      match = matches(:dean_vs_maria)
      match.moves << move =  Move.new( :notation => 'move it baby' )
      move.should_not be_valid
    end
    it 'should err if notation is ambiguous' do
      match = matches(:queenside_castled)
      match.moves << move = Move.new( :notation => 'Nf3' )
      move.should_not be_valid
    end
    
    it 'should disallow combined notation and coordinate move' do
      match = matches(:unstarted_match)
      lambda{
        m = Move.new( :notation => 'e4', :from_coord => 'e2', :to_coord => 'e4' )
      }.should raise_error
    end
    it 'should notate a noncapturing knight move' do
      match = matches(:unstarted_match)
      match.moves << move = Move.new( :from_coord => 'b1', :to_coord => 'c3' ) 
      move.notation.should == 'Nc3'
    end
    
    it 'should notate noncapturing pawn move' do
      match = matches(:unstarted_match)
      match.moves << Move.new( :from_coord => 'd2', :to_coord => 'd4' ) #queens pawn
      match.moves.last.notation.should == 'd4'
      
      match.moves << Move.new( :from_coord => 'e7', :to_coord => 'e5' ) 
      match.moves.last.notation.should == 'e5'
      
      match.moves << Move.new( :from_coord => 'd4', :to_coord => 'e5' ) 
      match.moves.last.notation.should == 'dxe5'
    end

    it 'should notate white kingside castle' do
      match = matches(:dean_vs_maria)
      match.moves << castle = Move.new( :from_coord => 'e1', :to_coord => 'g1' ) 
      
      castle.should be_valid
      match.moves.last.notation.should == 'O-O'
      
    end
    
    it 'should notate white queenside castle' do
      match = matches(:queenside_castled)
      match.moves << Move.new( :from_coord => 'e1', :to_coord => 'c1' ) 
      with(match.moves.last) do |mv|
        mv.castled.should == 1
        mv.notation.should == 'O-O-O'
      end
    end
    
    it 'should notate check if no intervening piece blocks check' do
      match = matches(:dean_vs_paul)
      match.moves << move = Move.new( :from_coord => 'f8', :to_coord => 'b4' ) 
      move.notation.should == 'Bb4+'
    end

    it 'should not notate check if an intervening piece blocks check' do
      match = matches(:dean_vs_paul)
      match.moves << Move.new( :from_coord => 'f1', :to_coord => 'b5' ) 
      match.moves.last.notation.should == 'Bb5'
    end
  
    it 'should allow move from notation only' do
      match = matches(:dean_vs_paul)
      match.moves << move = Move.new( :notation => 'Bb5' )
      
      move.from_coord.should == 'f1'
      move.to_coord.should == 'b5'
    end
    
    it 'should allow move from notation only for pawn' do
      match = matches(:dean_vs_paul)
      match.moves << move = Move.new( :notation => 'a4' )
      
      move.from_coord.should == 'a2'
      move.to_coord.should == 'a4'
    end
    
    it 'should err for a move with incorrect notation' do
      match = matches(:dean_vs_paul)
      
      #models can raise errors, controllers ultimately should not
      match.moves << move= Move.new( :notation => 'Bb3' )
      move.should_not be_valid
    end

  end
end
