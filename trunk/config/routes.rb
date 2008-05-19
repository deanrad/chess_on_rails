ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # Default routes - facebook and non
  map.facebook_root '', :controller => "fbuser", :conditions => {:canvas => true}
  map.root :controller => "authentication", :conditions => {:canvas => false}

  # move routes still in need of unfuddling
  map.notation 'move/notate', :controller=>'move', :action=>'notate'
  map.creation 'move/create', :controller=>'move', :action=>'create'

  # typical route for actions over match
  map.match ':controller/:id/:action'

  #map.match_pieces 'match/:id/pieces.xml', :controller => 'match', :action=>'pieces', :format=>'xml'
  #map.match_show   'match/show/:id', :controller => 'match', :action=>'show'
  #map.match_resign 'match/resign/:id', :controller => 'match', :action=>'resign'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:id/:action'
  map.connect ':controller/:action'
  map.connect ':controller/:id/:action.:format' , :defaults => {:format => 'html'}

  #map.match_action 'match/show/:id/:action', :controller => 'match', :format => 'html'
  #map.match_action 'match/show/:id/:action.:format', :controller => 'match'
  

  #Allow typical REST commands over match (possibly overkill)
  #map.resources :match
  
  
end
