require File.expand_path(File.dirname(__FILE__) + '/../../../../../spec/spec_helper')

describe Chat do

  before(:each) do
    @match = matches(:dean_vs_paul)
    @valid_attrs = {:match_id => @match.id, :player_id => players(:dean).id }
  end

  it 'should replace an action in text with its behavior when viewed by opponent and not yet cancelled' do
    c = Chat.create( @valid_attrs.merge( :text => '/shake' ) )
    display_text = c.display_text( players(:paul) )

    # <script type='text/javascript'>Effect.Shake('board_table');</script>"
    display_text.should include(I18n.t("chat_action_shake_action"))

    c.reload.text.should_not include(I18n.t("chat_action_shake_action"))
  end

  it 'should not be cancelled if it is the most recent chat' do
     c = Chat.create( @valid_attrs.merge( :text => '/shake' ) )
     c.should_not be_canceled
  end

  it 'should be cancelled if its not the most recent chat' do
    c0 = Chat.create( @valid_attrs.merge( :text => 'c 1' ) )
    c1 = Chat.create( @valid_attrs.merge( :text => 'c 2' ) )

    c0.should be_canceled 
  end
end
