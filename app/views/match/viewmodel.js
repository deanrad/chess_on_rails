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
    console.log('initiating poll num:' + this.poll_count)
    this.poll_count += 1;
    <%= remote_function(:url => {:action => :update_view, :format => :js}) %>
  }
};

var client_config = {
  poll_interval:            3
};

ko.applyBindings(document.body, game_view_model);
