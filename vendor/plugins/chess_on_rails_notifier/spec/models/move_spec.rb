require File.expand_path(File.dirname(__FILE__) + '/../../../../../spec/spec_helper')

describe 'Move with notification options' do

  before(:each) do
    ActionMailer::Base.deliveries.clear
  end

  it 'should send an email if a move is made after a configured time since the last move' do
    Move.stubs(:time_since_last_moved).returns( Time.now -3601 )

    matches(:castled).moves << m = Move.new(:notation => "d5")
    ActionMailer::Base.deliveries.length.should >= 1
  end
end
