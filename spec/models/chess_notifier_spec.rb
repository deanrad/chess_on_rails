require 'spec/spec_helper'

describe ChessNotifier do
  before(:each) do
    ActionMailer::Base.deliveries.clear
  end

  it 'should create an opponent_moved email when told' do
    ChessNotifier.deliver_opponent_moved( players(:dean), players(:paul), matches(:dean_vs_paul).moves.last)
    ActionMailer::Base.deliveries.length.should >= 1
  end

  it 'should create an match_created email when told' do
    ChessNotifier.deliver_match_created( players(:dean), players(:paul), matches(:dean_vs_paul) )
    ActionMailer::Base.deliveries.length.should >= 1
  end
end
