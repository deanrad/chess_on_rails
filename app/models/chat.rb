# A list of messages said by a player within a match
class Chat < ActiveRecord::Base
  belongs_to :match
  belongs_to :player

  # Modifies self.text and returns it so it has additional markup beyond the 
  # originally entered text. 
  def display_text(current_player, is_most_recent_chat)
    link_notations
    actify_actions(current_player, is_most_recent_chat)
    self.text 
  end

  # Actions are IRC-style commands starting with slash "/" which get replaced
  # with script or other 'active content' for recipients but not their sender.
  # Example: /shake 
  #   for sender becomes : (shakes board)
  #   for recip  becomes : (shakes board)<script>Effect.Shake('board_table')</script>
  def actify_actions(current_player, is_most_recent_chat)
    ['shake'].each do |action|
      view_text = I18n.t "chat_action_#{action}_text"
      self.text = self.text.gsub("/#{action}", view_text)
      if (current_player != self.player) && is_most_recent_chat
        self.text = self.text.gsub(view_text, view_text + I18n.t("chat_action_#{action}_action") )
      end
    end
  end

  # replaces references to notations in the chat passed with links
  # to the moves they represented, or leaves them unreplaced
  # aware of: match.moves, SAN, JS:set_board(move, allowed_moves)
  def link_notations
    match_moves = match.moves.reverse
    move_count  = match_moves.count

    self.text.gsub!(SAN::REGEXP) do |notation| 
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
