module ChatsHelper
  # Returns the processed text to be displayed for the chat. 
  def process_chat( chat, is_last = false )
    chat.text = link_notations(chat.text)
    chat.text = actify_actions(chat, is_last)
  end

  # actions are IRC-style commands starting with slash "/" which get replaced
  # with script or other 'active content' for recipients but not their sender
  # Example: /shake 
  #   for sender becomes : (shakes board)
  #   for recip  becomes : (shakes board)<script>Effect.Shake('board_table')</script>
  def actify_actions(chat, is_last)
    ['shake'].each do |action|
      view_text = I18n.t "chat_action_#{action}_text"
      chat.text = chat.text.gsub("/#{action}", view_text)
      if (current_player != chat.player) && is_last
        chat.text = chat.text.gsub(view_text, view_text + I18n.t("chat_action_#{action}_action") )
      end
    end
    chat.text
  end

  # replaces references to notations in the chat passed with links
  # to the moves they represented, or leaves them unreplaced
  # aware of: match.moves, SAN, JS:set_board(move, allowed_moves)
  def link_notations( txt )
    match_moves = match.moves.reverse
    move_count  = match_moves.count

    txt.gsub(SAN::REGEXP) do |notation| 
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
