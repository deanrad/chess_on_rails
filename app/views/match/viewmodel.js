// Because client state will change while the page is loaded, we set up an object
// with fields to track it, and methods to manipulate it. This is called a viewmodel.
// Then we bind (using HTML5 data-bind attributes and knockout syntax) DOM elements
// to the viewmodel, and updating happens automatically as the viewmodel is changed
// whether by user-interaction, or AJAX polls.
var game_view_model = {
  
  last_move_id:             <%= last_move ? last_move.id : 'null' %>,
  last_chat_id:             <%= last_chat ? last_chat.id : 'null' %>,
  poll_count:               0,

  your_turn:                new ko.observable(<%= your_turn %>),
  allowed_moves:            <%= board.allowed_moves.to_json %>,
  last_move:                <%= last_move ? last_move.to_json : Move.new.to_json %>,
  
  displayed_move_num:       new ko.observable(<%= match.moves.count %>),
  all_moves:                new ko.observableArray([]),
  all_chats:                new ko.observableArray([]),
  
  sync_page:                function(){
    //TODO any items not bound via knockout - update them here
  },
  unbind_draggables:        function(){
    console.log('unbinding draggables')
  },
  bind_draggables:          function(){
    console.log('binding draggables')
  },
  add_move:                 function( mv ){
    console.log('tracking move:' + mv)
    this.all_moves.push( mv );
  },
  poll:                     function(){
    console.log('initiating poll num:' + game_view_model.poll_count)
    game_view_model.poll_count += 1;
    
    $.get( '<%= url_for :action => 'update_view', :format => :js %>',
        { 
          last_move_id:       game_view_model.last_move_id, 
          last_chat_id:       game_view_model.last_chat_id,
          authenticity_token: '<%= form_authenticity_token %>' 
        },
        function(data){
          eval(data);
        }    
    ); 

    var new_interval = client_config.interval_for_poll( this.poll_count );
    console.log('next poll in ' + new_interval + ' seconds');
    window.setTimeout( game_view_model.poll,  new_interval * 1000);
  }
};

var client_config = {
  initial_poll_interval:    3,
  interval_for_poll:  function( poll_num ){
    if (isNaN(poll_num) || poll_num <  10 )
      return 3;
    else if (poll_num < 20 )
      return 10;
    else if (poll_num < 50 )
      return 60;
    else 
      return 3600;
  }
};

// Start knockout's tracking of auto-updating items
ko.applyBindings(document.body, game_view_model);

//TODO kickoff polling loop
window.setTimeout( game_view_model.poll, client_config.initial_poll_interval * 1000 )