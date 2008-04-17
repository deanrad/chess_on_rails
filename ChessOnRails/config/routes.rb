ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  #Allow typical REST commands over match (possibly overkill)
  map.resources :match

  # soon to be changed to: 
  #   map.match_pieces 'match/:id/pieces.:format', :controller => 'match', :action=>'pieces'	
  map.match_pieces 'match/:id/pieces.xml', :controller => 'match', :action=>'pieces', :format=>'xml'
  
  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
end
