require File.expand_path(File.dirname(__FILE__) + '/../../../../../spec/spec_helper')

describe EventsController do
  controller_name 'events'

  before(:all) do
#    @two_moves_made = matches(:ready_to_capture)
    r = @response
  end

  it 'should be routed under matches/' do; end

  it 'should have an event for every move' do
    m = matches(:ready_to_capture)
    m.chats << Chat.new( :player => m.white, :text => 'Hey Testy' )

    m.moves.length.should == 2

    get :index, { :match_id => m.id }

    assigns[:event_hashes].length.should == m.moves.length + m.chats.length
    pp assigns[:event_hashes]

    #response.should be_success
    #json = JSON.load( response.body )
    #json.length.should == m.moves.length + m.chats.length
    #pp json
  end

  # it 'should have sequential ids starting from 1'
end
