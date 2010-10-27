ActionController::Routing::Routes.draw do |map|

  # The priority is based upon order of creation: first created -> highest priority.

  map.root :controller => "authentication"

  map.auth       'authentication/:action',  :controller => 'authentication'
  map.login      'authentication/login',    :controller => 'authentication', :action => 'login'
  map.logout     'authentication/logout',   :controller => 'authentication', :action => 'logout'
  map.register   'authentication/register', :controller => 'authentication', :action => 'register'

  #allow moving from CURL - Although GET generally not acceptable, post won't work without the forgery protection
  map.create_move 'match/:match_id/moves/create', :controller => 'move', :action => 'create'

  map.match_players 'match/players.js', :controller => 'match', :action => 'players'

  map.resources :match , :except => [:delete], :shallow => true, :collection => { :create => :post } do |match|
    match.resources :moves, :controller => :move, :collection => { :create => :post }
    match.resource :chat
  end

  # Install the default routes as the lowest priority.
  map.connect ':controller/:id/:action'
  map.connect ':controller/:id/:action.:format'  
  
end
