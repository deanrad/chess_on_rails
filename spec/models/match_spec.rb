require 'spec/spec_helper'

describe Match do
  before(:each) do
    @match = matches(:dean_vs_paul)
    # The first to move is always white except when resuming from an older board,
    # we just want to be explicit here 
    @match.stubs(:first_to_move).returns(:white)
  end

  describe 'Turn Alternation' do
    it 'shall be whites turn to move when no move has been made' do
      @match.moves.stubs(:count).returns(0)
      @match.player_to_move.should == @match.white
      @match.player_to_move.should_not == @match.black
      @match.side_to_move.should == :white
    end

    it 'shall be blacks turn to move when an odd number of moves have been made' do
      [1,3,19].each do |oddball|
        @match.moves.stubs(:count).returns(oddball)
        @match.player_to_move.should == @match.black
        @match.player_to_move.should_not == @match.white
        @match.side_to_move.should == :black
      end
    end

    it 'should think its a players move when white is to move and that player is white' do
      @match.moves.stubs(:count).returns(0)
      @match.player_to_move.should == @match.white
    end

    it 'should think its a players move when black is to move and that player is black' do
      @match.moves.stubs(:count).returns(1)
      @match.player_to_move.should == @match.black
    end

    it 'should think its a players move when that player is playing both sides of the game' do
      m = matches(:self_love)
      m.moves.stubs(:count).returns(0)
      m.player_to_move.should == m.white

      m.moves.stubs(:count).returns(1)
      m.player_to_move.should == m.white
    end
  end

  describe 'Ending scenarios' do
    it 'should deactivate match and pronounce opponent as winner if resigned' do
      @match.resign( @match.white )
      @match.winning_player.should == @match.black
      @match.active.should == 0
    end
  end

  describe 'API' do
    it 'should allow for creation of a match given an array of two players (white, black)' do
      m = Match.create(:players => [players(:maria), players(:dean)] )
      m.white.should == players(:maria)
      m.black.should == players(:dean)
    end
    it 'should answer whether a player is a participant in a match' do
      m = @match
      m.is_playing?( m.white ).should == true
      m.is_playing?( m.black ).should == true
      m.is_playing?( Player.new ).should == false
    end
  end

  describe 'Automated PGN Tests - Run Through Without Error' do
    # In addition to the fixtures named in matches.yml, we can refer to a pgn file in the 
    # test/fixtures/matches directory by specifying its name as a symbol 
    include PGN::Fixtures

    it 'should go through rubinstein_immortal.pgn' do
      pending
      m = matches(:rubinstein_immortal)
      m.errors.should be_empty
    end

  end
end
