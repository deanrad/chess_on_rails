# Provides constants and behavior for chats that are actually actions, or question/answer
# pairs of chat.
module ChatActions

  ACTION_LIST=[:shake, :offer_draw]

  # Modifies self.text and returns it so it has additional markup beyond the 
  # originally entered text. Each player may see this differently, pass the 
  # player viewing this display text to get.
  def display_text(for_player = nil)
    return @display_text if @display_text
    link_notations
    actify_actions(for_player) if for_player
    @display_text
  end

  # Iteration 1: A chat is canceled if another chat in that match lists it
  # in its responding_to_chat_id. This may be best done by database?  
  def canceled?
    !! match.chats.detect{|c| c.responding_to_chat_id == self.id }
  end

  # Actions are IRC-style commands starting with slash "/" which get replaced
  # with script or other 'active content' for recipients but not their sender.
  # Example: /shake 
  #   for sender becomes : (shakes board)
  #   for recip  becomes : (shakes board)<script>Effect.Shake('board_table')</script>
  def actify_actions(for_player)
    ACTION_LIST.each do |action|
      view_text = I18n.t "chat_actions.#{action}.text"
      # always display the text of the chat
      @display_text.gsub!("/#{action}", view_text)
      
      # for uncanceled chats viewed by the other party (not the originator) we also get the text
      if (for_player != self.player) && !canceled?
        @display_text.gsub!(view_text, view_text + I18n.t("chat_actions.#{action}.action") )
      end
    end
  end

  # replaces references to notations in the chat passed with links
  # to the moves they represented, or leaves them unreplaced
  # aware of: match.moves, SAN, JS:set_board(move, allowed_moves)
  def link_notations
    match_moves = match.moves.reverse
    move_count  = match_moves.length

    @display_text = self.text.gsub(SAN::REGEXP) do |notation| 
      move_num = nil
      match_moves.each_with_index{ |mv, idx| move_num=move_count-idx if mv.notation == notation}
      if move_num
        %Q{<a href="##{move_num}" onclick="set_board(#{move_num}, [])">#{notation}</a>}
      else
        notation
      end
    end
  end

end
