class ChatsController < ApplicationController
  unloadable # fixes copious errors per http://strd6.com/?p=250

  before_filter :authorize

  # This controller only serves the text of the chats, not navigation, etc..
  layout false 

  # Show this match's chats
  def show
    # Note: automatic caching results in 304s when there are no new chats, but the browser
    # still reapplies its cached document to the DOM. This results in any actions (board shaking,
    # for example) happening again. 
  end

  # Post a new chat to this match. It is sanitized, and moves mentioned in the
  # chat become hyperlinks upon showing the chat
  def create
    @chat = match.chats.build( params[:chat] )

    @chat.text.gsub!( '<', '&lt;' ).gsub!( '>', '&gt;' ) rescue nil
    @chat.player_id = current_player.id

    @chat.save!
    render :action => :show
  end

end
