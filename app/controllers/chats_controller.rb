class ChatsController < ApplicationController
  before_filter :authorize

  # This controller only serves the text of the chats, not navigation, etc..
  layout false 

  # Show this match's chats
  def show; end

  # Post a new chat to this match. It is sanitized, and moves mentioned in the
  # chat become hyperlinks upon showing the chat
  def create
    chat = Chat.new(params[:chat])
    chat.text.gsub!( '<', '&lt;' ).gsub!( '>', '&gt;' ) rescue nil
    chat.match_id = params[:match_id]
    chat.player_id = current_player.id

    chat.save!
    render :action => :show
  end

end
