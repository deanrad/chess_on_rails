var clientConfig= {
  initial_poll_interval: 2,
  your_turn_msg: 'Your Turn - '
}
// Because client state will change while the page is loaded, we set up an object
// with fields to track it, and methods to manipulate it. This is called a viewmodel.
// Then we bind (using HTML5 data-bind attributes and knockout syntax) DOM elements
// to the viewmodel, and updating happens automatically as the viewmodel is changed
// whether by user-interaction, or AJAX polls.
var game_view_model = {
  
  last_move_id:             <%= last_move ? last_move.id : 'null' %>,
  last_chat_id:             <%= last_chat ? last_chat.id : 'null' %>,
  poll_count:               0,
  next_poll_in:             clientConfig.initial_poll_interval,             

  your_turn:                new ko.observable(<%= your_turn %>),
  side_to_move:             new ko.observable('<%= match.side_to_move.to_s.titleize %>'),
  allowed_moves:            <%= board.allowed_moves.to_json %>,
  last_move:                <%= last_move ? last_move.to_json : Move.new.to_json %>,
  
  display_board:            new ko.observable(<%= match.moves.count %>),
  chat_msg:                 new ko.observable(''),

  all_moves:                new ko.observableArray([
    <%= match.moves.map(&:to_json).join(",\n    ") %>
  ]),

  all_chats:                new ko.observableArray([
    <%= match.chats.map(&:to_json).join(",\n    ") %>
  ]),

  all_boards:                new ko.observableArray([
    <%= match.boards.map(&:to_json).join(",\n    ") %>
  ]),
  
  // Does not follow the subscriber model, since its too busy..
  add_move:                 function( mv, board ){
    if ( game_view_model.all_moves().map( function(mv){ return mv.id } ).indexOf(mv.id) > -1 ){
      console.log('already have move ' + mv.id + ', skipping ..')
      return;
    }
    console.log('adding move ' + mv.id)
    this.all_moves.push( mv );
    this.all_boards.push( board );

    //if we are not caught up, we only need to update on the final move known about
    if( mv.id == this.last_move_id){
      my_index = this.all_boards.indexOf(board)
      this.add_to_move_list( mv, my_index );
      this.display_board( my_index );
    }

    this.reset_poller();
  },

  add_to_move_list:         function( mv, index ) {
    console.log('adding move ' + mv.notation + ' to move list at index ' + index);
    mv.index = index;
    if( index % 2 == 1 ){
      mv.ply_count = Math.ceil(index/2); mv.index = index
      template = '<div class="move_w" id="move_list_${index}" onclick="game_view_model.display_board(${index})">${ply_count}. ${notation}</div>';
    } 
    else{
      template = '<div class="move_b" id="move_list_${index}" onclick="game_view_model.display_board(${index})">${notation}</div>';
    }
    $("#move_list").append( $.tmpl( template, mv ) )
    moveDiv = document.getElementById('move_list');
    moveDiv.scrollTop = moveDiv.scrollHeight;
		
  },

  layout_board:             function(board_idx) {
    console.log('Laying out board ' + board_idx  );
    $('td.piece_container').empty();
    $('td.piece_container').append("&nbsp;");
    $.each( game_view_model.all_boards()[board_idx], function (pos, piece) { 

        //TODO use template
        var img = '<img id="' + piece.board_id + '" class="piece" src="/images/sets/default/' + piece.img + '.png" />';

        $("#" + pos).empty();
        $("#" + pos).append(img);
      })
  },

  // Lays out the board and enables/disables moves via drag/drop mediated thru CSS
  set_display_board:         function(mvidx) {
     game_view_model.layout_board(mvidx);

     //get rid of, then replace draggables
     $('td.piece_container img').draggable("destroy");
     
     //if this is the latest move and your turn, rebind allowed moves/draggables
     if( mvidx == game_view_model.all_boards().length-1 && game_view_model.your_turn()){
        console.log('rebinding draggables')
        $('td.piece_container img').removeClass();
        
        // restore draggability
        $('td.piece_container').each( 
          function(idx, elem) {
            sq_id = $(this).attr('id')

            //set the piece therein to have css classes for each allowed move
            allowed = game_view_model.allowed_moves[sq_id]
            allowed = allowed == undefined ? '' : allowed.join(' ')
            $('img', this).addClass( "piece " + allowed );
            $('img', this).draggable( {revert: 'invalid', grid: [42, 42] } );
          }
        );
     } 

     // show the move that brought this board to this state
     $('td.piece_container').removeClass('last-move-from last-move-to last-move-to-x');
     if(mvidx > 0){
       mv = game_view_model.all_moves()[mvidx - 1];
       $('#' + mv.from_coord ).addClass('last-move-from')
       $('#' + mv.to_coord   ).addClass('last-move-to' + (mv.captured_piece_coord == undefined ? '' : '-x') )
     }
     
     // highlight this move in the movelist
     $("#move_list div").removeClass('move_list_current');
     $("#move_list_" + mvidx).addClass('move_list_current');
  },
  can_play_previous:         function(){
    return (game_view_model.display_board() > 0);
  },
  can_play_next:             function(){
    return (game_view_model.display_board() < game_view_model.all_boards().length-1);
  },
  decrement_displayed_move:  function(){
    cur_mvidx = game_view_model.display_board();
    mvidx = cur_mvidx == 0 ? 0 : cur_mvidx - 1;
    console.log("Setting move to " + mvidx);
    game_view_model.display_board(mvidx);
  },
  increment_displayed_move:  function(){
    cur_mvidx = game_view_model.display_board();
    mvidx = (cur_mvidx == game_view_model.all_boards().length-1) ? game_view_model.all_boards().length-1 : cur_mvidx + 1
    console.log("Setting move to " + mvidx)
    game_view_model.display_board(mvidx);
  },
  display_first_move:        function(){
    game_view_model.display_board(0);
  },
  display_last_move:         function(){
    game_view_model.display_board(game_view_model.all_boards().length-1);
  },
  submit_chat:               function(){
    $.post( "<%= match_chat_path(match) %>",
        { 
          'chat[text]':         game_view_model.chat_msg(),
          authenticity_token: '<%= form_authenticity_token %>' 
        },
        function(data){
          game_view_model.chat_msg('');
          game_view_model.reset_poller();
        } 
    );   
  },
  
  add_chat:                 function( ch ){
    if ( game_view_model.all_chats().map( function(ch){ return ch.id } ).indexOf(ch.id) > -1 ){
      console.log('already have chat ' + ch.id + ', skipping ..')
      return;
    }
    
    console.log('adding chat ' + ch.id)
    this.all_chats.push(ch);
    var chatTemplate = '<div class="chat_line"><b title="${time}">${player}:</b> ${text} </div>';
    render  = $.tmpl( chatTemplate, ch );
		$('#chat_window').append( render );
		chatDiv = document.getElementById('chat_window');
    chatDiv.scrollTop = chatDiv.scrollHeight;

    this.reset_poller();
  },

  increment_poll:           function(){
    game_view_model.poll_count += 1;
    
    if ( game_view_model.poll_count <=  15 )
      game_view_model.next_poll_in = clientConfig.initial_poll_interval;
    else if (game_view_model.poll_count <= 30 )
      game_view_model.next_poll_in = 5;
    else if (game_view_model.poll_count <= 50 )
      game_view_model.next_poll_in = 30;
      else if (game_view_model.poll_count <= 100 )
        game_view_model.next_poll_in = 60;
    else 
      game_view_model.next_poll_in = 3600;
  },

  reset_poller:           function(){
    this.poll_count = 0;
    this.next_poll_in = clientConfig.initial_poll_interval;
    window.setTimeout( game_view_model.poll,  game_view_model.next_poll_in * 1000);
  },

  // Performs a poll, evaling what comes back, and schedules the next poll.
  poll:                     function(){
    game_view_model.increment_poll();
    console.log('initiating poll num: ' + game_view_model.poll_count + ' - next poll in ' + game_view_model.next_poll_in + ' seconds')
    
    $.get( "<%= url_for :action => 'update_view', :format => :js %>",
        { 
          last_move_id:       game_view_model.last_move_id, 
          last_chat_id:       game_view_model.last_chat_id,
          authenticity_token: '<%= form_authenticity_token %>' 
        },
        function(data){
          eval(data);
        }    
    ); 

    window.setTimeout( game_view_model.poll,  game_view_model.next_poll_in * 1000);
  },
  submit_move:              function(from, to){
    $("#board_table").addClass('busy');
    $.post( "<%= create_match_moves_path(match.id) %>",
        { 
          'move[match_id]':           <%= match.id %>, 
          'move[from_coord]':         from,
          'move[to_coord]':           to,
          authenticity_token: '<%= form_authenticity_token %>' 
        },
        function(data){
          console.log('AJAX POST returned: ' + data);
          game_view_model.poll();
          game_view_model.reset_poller();
          $("#board_table").removeClass('busy');
        }    
    ); 
    
  }
};

// Start knockout's tracking of auto-updating items
ko.applyBindings(document.body, game_view_model);

// Set up subscriptions on interesting items
game_view_model.display_board.subscribe( game_view_model.set_display_board );
game_view_model.all_moves.subscribe( function(){
  document.title = document.title.replace( clientConfig.your_turn_msg, '' );

  if( game_view_model.your_turn() ){
    document.title = clientConfig.your_turn_msg + document.title
  }
})

// Show first move
game_view_model.display_board( game_view_model.all_boards().length - 1 );

// Allow for droppability
$('td.piece_container').each( 
  function() {
    sq_id = $(this).attr('id')
    $(this).droppable({ 
        accept: '.'+sq_id,
        hoverClass: 'drop-allowed', //TODO hoverClass not working
        drop: function(evt, ui){
          from = ui.draggable.parent().attr('id');
          to = $(this).attr('id');
          console.log(from  + ' dropped on ' + to );
          game_view_model.submit_move( from, to )
        }
    });
  });

// Allow for keyboard handling - arrow keys move back/forth through history
// If focused in a text field, hit Esc to return to general keyboard mode
$('body').keyup(function(event) {
    if ($(event.target).is(':not(input, textarea)')) {
      if (event.keyCode == 37) // left
        game_view_model.decrement_displayed_move();
      if (event.keyCode == 39) // right
        game_view_model.increment_displayed_move();
    }
});
$('body').keypress(function(event) {
    if ($(event.target).is(':not(input, textarea)')) {
      if (event.keyCode == 97) // 'c' for chat
        $('#chat_msg').focus();
      if (event.keyCode == 109) // 'm' for move
        $('#move_notation').focus();
        
      return false; //dont register the keypress in the field
    }
});
$(document).ready(function(){
  $("#move_notation").focus();
});

// Kickoff polling loop
window.setTimeout( game_view_model.poll, game_view_model.next_poll_in * 1000 )