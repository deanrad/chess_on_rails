view.active(  <%= match.active? %> )
view.outcome( '<%= match.outcome %>' )

// Update 'current status' fields
view.last_move_id =  <%= last_move ? last_move.id : 'null' %>;
view.last_chat_id =  <%= last_chat ? last_chat.id : 'null' %>;

view.your_turn(    <%= your_turn %> );
view.side_to_move( '<%= match.side_to_move.to_s.titleize %>' );

// update the allowed moves from the current board
view.allowed_moves = <%= board.allowed_moves.to_json %>;

view.my_next_matches( <%= my_next_matches %> )

// Update any moves/boards they haven't seen;
<% match.moves_more_recent_than( params[:last_move_id].to_i ).each do |move| -%>
view.add_move( 
  <%= move.to_json %>,
  <%= move.match.board.to_json %>
);
<% end -%>

// Update any chats they haven't seen;
<% match.chats_more_recent_than( params[:last_chat_id].to_i ).each do |chat| -%>
view.add_chat( <%= chat.to_json %> );
<% end -%>

