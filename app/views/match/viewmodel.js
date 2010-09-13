var clientConfig= {
  initial_poll_interval: 3,
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
  allowed_moves:            <%= board.allowed_moves.to_json %>,
  last_move:                <%= last_move ? last_move.to_json : Move.new.to_json %>,
  
  displayed_move_num:       new ko.observable(<%= match.moves.count %>),

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

    if( mv.id == this.last_move_id){
      this.redraw_board( board );
    }

    this.reset_poller();
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

    this.reset_poller();
  },
  increment_poll:           function(){
    game_view_model.poll_count += 1;
    
    if ( game_view_model.poll_count <=  10 )
      game_view_model.next_poll_in = 3;
    else if (game_view_model.poll_count <= 20 )
      game_view_model.next_poll_in = 10;
    else if (game_view_model.poll_count <= 50 )
      game_view_model.next_poll_in = 60;
    else 
      game_view_model.next_poll_in = 3600;
  },
  reset_poller:           function(){
    this.poll_count = 0;
    this.next_poll_in = clientConfig.initial_poll_interval;
  },
  unbind_draggables:        function(){
    console.log('unbinding draggables')
  },
  bind_draggables:          function(){
    console.log('binding draggables')
  },
  set_display_move:         function( move_num ){
    //TODO allow playback via setting this parameter
  },
  redraw_board:             function(board) {
    console.log('Redrawing board.')
    $('td.piece_container').each( 
       function( elem ){ 
         try{
  	       elem.empty();
         }
         catch(ex){
  	       alert(ex); return;
         }
       }
    );
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
  update_title:             function(your_turn){
    document.title = document.title.replace( clientConfig.your_turn_msg, '' );
    if (your_turn){
      document.title = clientConfig.your_turn_msg + document.title
    }
  },
  update_move_list:         function(mv){
    $("#move_list").append( mv.notation );
  }
};

// Start knockout's tracking of auto-updating items
ko.applyBindings(document.body, game_view_model);

// Set up subscriptions on interesting items
game_view_model.your_turn.subscribe( game_view_model.update_title );

//TODO kickoff polling loop
window.setTimeout( game_view_model.poll, game_view_model.next_poll_in * 1000 )