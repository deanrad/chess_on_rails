var clientConfig= {
  initial_poll_interval: 2,
  your_turn_msg: 'Your Turn - '
}
// Because client state will change while the page is loaded, we set up an object
// with fields to track it, and methods to manipulate it. This is called a viewmodel.
// Then we bind (using HTML5 data-bind attributes and knockout syntax) DOM elements
// to the viewmodel, and updating happens automatically as the viewmodel is changed
// whether by user-interaction, or AJAX polls.
var view = {
  
  last_move_id:             <%= last_move ? last_move.id : 'null' %>,
  last_chat_id:             <%= last_chat ? last_chat.id : 'null' %>,
  poll_count:               0,
  next_poll_in:             clientConfig.initial_poll_interval,             

  your_turn:                new ko.observable(<%= your_turn %>),
  side_to_move:             new ko.observable('<%= match.side_to_move.to_s.titleize %>'),
  allowed_moves:            <%= board.allowed_moves.to_json %>,
  last_move:                <%= last_move ? last_move.to_json : Move.new.to_json %>,
  selected_piece_coord:     new ko.observable(null),
  
  display_board:            new ko.observable(<%= match.moves.count %>),
  chat_msg:                 new ko.observable(''), //the message the user is entering

  all_moves:                new ko.observableArray([
    <%= match.moves.map(&:to_json).join(",\n    ") %>
  ]),

  all_chats:                new ko.observableArray([
    <%= match.chats.map(&:to_json).join(",\n    ") %>
  ]),

  all_boards:                new ko.observableArray([
    <%= match.boards.map(&:to_json).join(",\n    ") %>
  ]),
  
  all_graveyards:            new ko.observableArray([
    <%= match.boards.map{|b| b.graveyard.to_json}.join(",\n   ") %>
  ]),

  server_messages:          new ko.observable(""),
  
  // Does not follow the subscriber model, since its too busy..
  add_move:                 function( mv, board ){
    if ( view.all_moves().map( function(mv){ return mv.id } ).indexOf(mv.id) > -1 ){
      console.log('already have move ' + mv.id + ', skipping ..')
      return;
    }
    console.log('adding move ' + mv.id)
    view.all_moves.push( mv );
    view.all_boards.push( board );

    //if we are not caught up, we only need to update on the final move known about
    if( mv.id == view.last_move_id){
      my_index = view.all_boards.indexOf(board)
      view.add_to_move_list( mv, my_index );
      view.display_board( my_index );
    }

    view.reset_poller();
  },

  add_to_move_list:         function( mv, index ) {
    console.log('adding move ' + mv.notation + ' to move list at index ' + index);
    mv.index = index;
    if( index % 2 == 1 ){
      mv.ply_count = Math.ceil(index/2); mv.index = index
      template = '<div class="move_w" id="move_list_${index}" onclick="view.display_board(${index})">${ply_count}. ${notation}</div>';
    } 
    else{
      template = '<div class="move_b" id="move_list_${index}" onclick="view.display_board(${index})">${notation}</div>';
    }
    $("#move_list").append( $.tmpl( template, mv ) )
    moveDiv = document.getElementById('move_list');
    moveDiv.scrollTop = moveDiv.scrollHeight;
		
  },

  layout_board:             function(board_idx) {
    console.log('Laying out board ' + board_idx  );
    $('td.piece_container').empty();
    $('td.piece_container').append("&nbsp;");
    $.each( view.all_boards()[board_idx], function (pos, piece) { 

        //TODO use template
        var img = '<img id="' + piece.board_id + '" class="piece" src="/images/sets/default/' + piece.img + '.png" />';

        $("#" + pos).empty();
        $("#" + pos).append(img);
      })
  },

  // Lays out the board and enables/disables moves via drag/drop mediated thru CSS
  set_display_board:         function(mvidx) {
     view.layout_board(mvidx);

     //get rid of, then replace draggables
     $('td.piece_container img').draggable("destroy");
     
     //if this is the latest move and your turn, rebind allowed moves/draggables
     if( mvidx == view.all_boards().length-1 && view.your_turn()){
        console.log('rebinding draggables')
        $('td.piece_container img').removeClass();
        
        // restore draggability
        $('td.piece_container').each( 
          function(idx, elem) {
            sq_id = $(this).attr('id')

            //set the piece therein to have css classes for each allowed move
            allowed = view.allowed_moves[sq_id]
            allowed = allowed == undefined ? '' : allowed.join(' ')
            $('img', this).addClass( "piece " + allowed );
            $('img', this).draggable( {revert: 'invalid', grid: [42, 42] } );
          }
        );
     } 

     // show the move that brought this board to this state
     $('td.piece_container').removeClass('last-move-from last-move-to last-move-to-x');
     if(mvidx > 0){
       mv = view.all_moves()[mvidx - 1];
       $('#' + mv.from_coord ).addClass('last-move-from')
       $('#' + mv.to_coord   ).addClass('last-move-to' + (mv.captured_piece_coord == undefined ? '' : '-x') )
     }
     
     // highlight this move in the movelist
     $("#move_list div").removeClass('move_list_current');
     $("#move_list_" + mvidx).addClass('move_list_current');
  },
  can_play_previous:         function(){
    return (view.display_board() > 0);
  },
  can_play_next:             function(){
    return (view.display_board() < view.all_boards().length-1);
  },
  decrement_displayed_move:  function(){
    cur_mvidx = view.display_board();
    mvidx = cur_mvidx == 0 ? 0 : cur_mvidx - 1;
    console.log("Setting move to " + mvidx);
    view.display_board(mvidx);
  },
  increment_displayed_move:  function(){
    cur_mvidx = view.display_board();
    mvidx = (cur_mvidx == view.all_boards().length-1) ? view.all_boards().length-1 : cur_mvidx + 1
    console.log("Setting move to " + mvidx)
    view.display_board(mvidx);
  },
  display_first_move:        function(){
    view.display_board(0);
  },
  display_last_move:         function(){
    view.display_board(view.all_boards().length-1);
  },
  submit_chat:               function(){
    $.post( "<%= match_chat_path(match) %>",
        { 
          'chat[text]':         view.chat_msg(),
          authenticity_token: '<%= form_authenticity_token %>' 
        },
        function(data){
          view.chat_msg('');
          view.reset_poller();
        } 
    );   
  },
  
  add_chat:                 function( ch ){
    if ( view.all_chats().map( function(ch){ return ch.id } ).indexOf(ch.id) > -1 ){
      console.log('already have chat ' + ch.id + ', skipping ..')
      return;
    }
    
    console.log('adding chat ' + ch.id)
    view.all_chats.push(ch);
    var chatTemplate = '<div class="chat_line"><b title="${time}">${player}:</b> ${text} </div>';
    render  = $.tmpl( chatTemplate, ch );
		$('#chat_window').append( render );
    view.scroll_chat('bottom')
    view.reset_poller();
  },
  scroll_chat:              function(where){
    chatDiv = document.getElementById('chat_window');
    chatDiv.scrollTop = (where=="bottom") ? chatDiv.scrollHeight : 0;
  },
  increment_poll:           function(){
    view.poll_count += 1;
    
    if ( view.poll_count <=  15 )
      view.next_poll_in = clientConfig.initial_poll_interval;
    else if (view.poll_count <= 30 )
      view.next_poll_in = 5;
    else if (view.poll_count <= 50 )
      view.next_poll_in = 30;
      else if (view.poll_count <= 100 )
        view.next_poll_in = 60;
    else 
      view.next_poll_in = 3600;
  },

  reset_poller:           function(){
    view.poll_count = 0;
    view.next_poll_in = clientConfig.initial_poll_interval;
    window.setTimeout( view.poll,  view.next_poll_in * 1000);
  },

  // Performs a poll, evaling what comes back, and schedules the next poll.
  poll:                     function(){
    view.increment_poll();
    console.log('initiating poll num: ' + view.poll_count + ' - next poll in ' + view.next_poll_in + ' seconds')
    
    $.get( "<%= url_for :action => 'update_view', :format => :js %>",
        { 
          last_move_id:       view.last_move_id, 
          last_chat_id:       view.last_chat_id,
          authenticity_token: '<%= form_authenticity_token %>' 
        },
        function(data){
          eval(data);
        }    
    ); 

    window.setTimeout( view.poll,  view.next_poll_in * 1000);
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
          if (data.errors){
            view.server_messages( data.errors )
            view.display_last_move();
          }else{
            view.server_messages( '' )
          }
          
          view.poll();
          view.reset_poller();
          $("#board_table").removeClass('busy');
        }    
    ); 
  },
  side_occupying:          function(coord){
    piece_id = $('#' + coord + ' img').attr('id')
    if(piece_id == undefined) return null;
    
    if( piece_id.match( /_w$/ ) )
      return 'white'
    if( piece_id.match( /_b$/ ) )
      return 'black'
  }
};

// Add functions that are dependent upon the values of other view model fields
// (and which will be memoized until their dependents change)
view.has_message =     new ko.dependentObservable(
  function(){
    return !(view.server_messages() == "")
  }
);

view.selected_piece_side = new ko.dependentObservable(
  function(){
    coord = view.selected_piece_coord();
    if( coord == null)
      return null
    else 
      return view.side_occupying(coord);
  }
)

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
          view.submit_move( from, to )
        }
    });
  });

// Allow for click-click moving
$('td.piece_container').click( 
  function() {
    clicked_id = $(this).attr('id')
    from_piece_coord = view.selected_piece_coord();
    
    if( from_piece_coord != null){
      if (view.side_occupying(clicked_id) == view.selected_piece_side() ){
        view.selected_piece_coord(clicked_id);        
      }
      else{
        view.selected_piece_coord(null);
        view.submit_move( from_piece_coord, clicked_id );
      }
    }
    else{
      if( view.your_turn() &&  
          $(this).has('img').length > 0 && 
          view.side_occupying(clicked_id) == view.side_to_move().toLowerCase() ){
        // console.log('selected piece ' + $(this).has('img').first().attr('id') );
        view.selected_piece_coord(clicked_id);
      }
      else {
        console.log('clicked sq ' + clicked_id);
      } // ignore it
    }
  }
);

// Allow for keyboard handling - arrow keys move back/forth through history
// If focused in a text field, hit Esc to return to general keyboard mode
$('body').keyup(function(event) {
    if ($(event.target).is(':not(:text)')) {
      if (event.keyCode == 37) // left
        view.decrement_displayed_move();
      if (event.keyCode == 39) // right
        view.increment_displayed_move();
    }
});
$('body').keypress(function(event) {
    if ($(event.target).is(':not(input, textarea)')) {
      if (event.keyCode == 97) // 'c' for chat
        { $('#chat_msg').focus(); return false; }
      if (event.keyCode == 109) // 'm' for move
        { $('#move_notation').focus(); return false; }
    }
});

// Start knockout's tracking of auto-updating items
ko.applyBindings(document.body, view);

// Set up subscriptions on interesting items
view.display_board.subscribe( view.set_display_board );
view.all_moves.subscribe( function(){
  document.title = document.title.replace( clientConfig.your_turn_msg, '' );
  if( view.your_turn() )
    document.title = clientConfig.your_turn_msg + document.title;
});

view.selected_piece_coord.subscribe( function(val) {
  $('td.piece_container').removeClass('selected-piece');
  $('#' + val).addClass('selected-piece');
  //HACK
  $('td.piece_container').css('background-color', '')
  $('#' + val).css('background-color', '#c6f1c6')
});

// Show first move
view.display_board( view.all_boards().length - 1 );

// Make sure latest chat is in focus
view.scroll_chat('bottom');
	
// Kickoff polling loop
window.setTimeout( view.poll, view.next_poll_in * 1000 )