require File.expand_path(File.dirname(__FILE__) + '/../../../../../spec/spec_helper')

describe Chat do

  before(:each) do
    @match = matches(:dean_vs_paul)
    @valid_attrs = {:match_id => @match.id, :player_id => players(:dean).id }
  end

  it 'should not replace an action that is not on the recognized list' do
    c = Chat.create( @valid_attrs.merge( :text => '/fungi' ) )
    ChatActions::ACTION_LIST.map(&:to_s).should_not include('/fungi')
    display_text = c.display_text( players(:paul) )
    display_text.should == '/fungi'
  end

  it 'should replace an action with its text and behavior when viewed by opponent and not yet cancelled' do
    c = Chat.create( @valid_attrs.merge( :text => '/shake' ) )
    display_text = c.display_text( players(:paul) )

    # <script type='text/javascript'>Effect.Shake('board_table');</script>"
    display_text.should include(I18n.t("chat_actions.shake.text"))
    display_text.should include(I18n.t("chat_actions.shake.action"))
  end

  it 'should replace an action with its text but not its behavior when viewed by opponent and cancelled' do
    c  = Chat.create( @valid_attrs.merge( :text => '/shake' ) )
    c1 = Chat.create( @valid_attrs.merge( :text => 'screw off !', :responding_to_chat_id => c.id ) )

    display_text = c.display_text( players(:paul) ) # viewed by the other player

    display_text.should     include(I18n.t("chat_actions.shake.text"))
    display_text.should_not include(I18n.t("chat_actions.shake.action"))
  end

  it 'should not be cancelled if it is the only chat' do
     c = Chat.create( @valid_attrs.merge( :text => '/shake' ) )
     c.should_not be_canceled
  end

  it 'should be cancelled if another chat cancels it' do
    c0 = Chat.create( @valid_attrs.merge( :text => 'c 0' ) )
    c1 = Chat.create( @valid_attrs.merge( :text => 'c 1', :responding_to_chat_id => c0.id ) )
      
    c0.should be_canceled 
    c1.should_not be_canceled 

    # Note: because AR sucks, you cannot change the status of a chat while its loaded !! 
    # The following would fail
    #c2 = Chat.create( @valid_attrs.merge( :text => 'c 2', :responding_to_chat_id => c1.id ) )
    #c1.should be_canceled

    # This succeeds though because reloading the chat reloads its match and all the others
    c2 = Chat.create( @valid_attrs.merge( :text => 'c 2', :responding_to_chat_id => c1.id ) )
    c1.reload
    c1.should be_canceled

  end
end
