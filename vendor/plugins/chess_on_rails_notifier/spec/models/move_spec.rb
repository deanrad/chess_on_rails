require File.expand_path(File.dirname(__FILE__) + '/../../../../../spec/spec_helper')

describe ChessNotifier do

  before(:each) do
    ActionMailer::Base.deliveries.clear
    @match = matches(:castled)
    @last_move = @match.moves.last
    @last_move.stubs(:update_computed_fields).returns(true) #necessary to allow save to complete
  end

  it 'should send an email if a move is made after a configured time since the last move' do
    @last_move.created_at -= (1.hour + 5.minutes)
    @last_move.save(false)

    @match.moves << m = Move.new(:notation => "a5")
    ActionMailer::Base.deliveries.length.should == 1
    with (ActionMailer::Base.deliveries[0]) do |email|
      email.to.should include(@match.player_to_move.user.email)
    end
  end

  it 'should not send an email for move made very recently' do
    @last_move.created_at = Time.now
    @last_move.save(false)

    @match.moves << m = Move.new(:notation => "a5")
    ActionMailer::Base.deliveries.length.should == 0
  end
end
