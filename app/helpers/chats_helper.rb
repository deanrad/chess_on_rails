module ChatsHelper
  # replaces references to notations in the chat passed with links
  # to the moves they represented, or leaves them unreplaced
  # aware of: match.moves, SAN, JS:set_board(move, allowed_moves)
  def link_notations( txt )
    match_moves = Match.find( params[:match_id] ).moves.reverse
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
