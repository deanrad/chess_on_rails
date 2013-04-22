require 'spec_helper'

describe Match do
  subject(:match) { FactoryGirl.create(:match) }
  
  context 'default values' do
    it 'should have 2 players' do
      match.players.count.should == 2
    end

    it 'should have a player1 and player2, different players' do
      p1, p2 = match.player1, match.player2
      p1.should_not == p2
    end
  end

end
