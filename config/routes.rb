ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Default routes - facebook or not
  map.facebook_root '', :controller => "fbuser", :conditions => {:canvas => true}
  map.root :controller => "authentication", :conditions => {:canvas => false}


  #place these higher to keep a nil :id from creeping in when caught by lower ones
  # (this only happens due to my preference for having :id earlier in the URL than convention
  map.matches      'match/', :controller => 'match', :action => 'index'
  map.match        'match/:id', :controller => 'match', :action => 'show'

  #map.new_match    'match/new', :controller => 'match', :action => 'new'
  map.match_action 'match/:action', :controller => 'match'
  
  map.fbuser  'fbuser/:action', :controller => 'fbuser'
  map.login   'authentication/login', :controller => 'authentication', :action => 'login'
  map.logout  'authentication/logout', :controller => 'authentication', :action => 'logout'

  map.create_move 'match/:match_id/moves/:notation', :controller => 'move', :action => 'create', :defaults => { :notation => nil }

  map.match_moves 'match/:match_id/moves', :controller => 'move', :action => 'index'
  
  # Install the default routes as the lowest priority.
  map.connect ':controller/:id/:action'
  map.connect ':controller/:id/:action.:format'  
  
end
