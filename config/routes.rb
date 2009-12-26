ActionController::Routing::Routes.draw do |map|

  # The priority is based upon order of creation: first created -> highest priority.

  # Default routes
  map.root :controller => "welcome"

  #allow moving from CURL - Although GET generally not acceptable, post won't work without the forgery protection
  map.create_move 'matches/:match_id/moves/:notation', :controller => 'matches', :action => 'create_move', :defaults => { :notation => nil }

  map.resources :matches , :except => [:delete], :collection => { :create => :post } do |match|
    match.resource  :moves, :only => [:create]
    match.resource  :chat 
    match.resources :events # events are the sum of moves and chats
  end

  # Gameplays are the records of a players involvment in a match
  map.resources :gameplays, :only => [:show, :update]

  # Sets of pieces, functionality courtesy of Sean
  map.resource :set, :member => {:change => :post}

  # allow shorthand for recognition but make sure helpers emit the real thing
  # map.connect 'match/:id',         :controller => 'matches', :action => 'show'
  # map.connect 'match/:id/:action', :controller => 'matches'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:id/:action'
  map.connect ':controller/:id/:action.:format'  

  
end
