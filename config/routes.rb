ActionController::Routing::Routes.draw do |map|

  # The priority is based upon order of creation: first created -> highest priority.

  # Default routes
  map.root :controller => "authentication"
  map.connect 'authentication/:action', :controller => 'authentication'

  map.resources :matches , :except => [:delete], :collection => { :create => :post } do |match|
    match.resource :moves, :only => [:create]
    # TODO match route for resign must be POST since destructive 
    match.resource :chat #TODO limit chat routes to those needed, :only => [:create, :index, :chat]
  end

  #allow moving from CURL - Although GET generally not acceptable, post won't work without the forgery protection
  map.create_move 'matches/:match_id/moves/:notation', :controller => 'matches', :action => 'create_move', :defaults => { :notation => nil }

  #allow updating of gameplays via REST
  map.resources :gameplays, :only => [:show, :update]

  #sets controller courtesy of Sean
  map.resource :set, :member => {:change => :post}

  # A controller that gives us a console in the process of the 
  map.test    'test/:action', :controller => 'test' if ENV['TEST_CONTROLLER']=="1"
  
  # Install the default routes as the lowest priority.
  map.connect ':controller/:id/:action'
  map.connect ':controller/:id/:action.:format'  

  
end
