require File.expand_path(File.dirname(__FILE__) + '/../../../../../spec/spec_helper')

describe ChatsController do
  controller_name 'chats'

  before(:each) do
    @chatter = players(:dean)
    @valid_attrs = [ {:match_id => matches(:dean_vs_paul).id, 
                     :chat => {:text => "whaddup fool"} }, 
                     {:player_id => @chatter.id} ]
    # this trickery (fine for specs, suspect for apps) allows nice calling syntax
    # See examples below
    def @valid_attrs.merge( params_hash, session_hash = nil )
      self[0].merge!( params_hash )
      self[1].merge!( session_hash ) if session_hash
      self
    end
  end
  
  it 'should accept a new chat via POST' do
    pending

    lambda{
      post :create, *@valid_attrs.merge( :chat => {:text => "whaddup fool"} )
    }.should change( Chat, :count ).by(1)

    with( assigns[:chat] ) do |c|
      c.should_not be_nil
      c.text.should == "whaddup fool"
      c.player_id.should == @chatter.id
    end

  end

  it 'should escape chars entered into a chat' do
    pending

    post :create, *@valid_attrs.merge( :chat => {:text => "this is <bold>"} )
    assigns[:chat].text.should == "this is &lt;bold&gt;"
  end
  
end
