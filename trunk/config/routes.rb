ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Default routes - facebook or not
  map.root :controller => "authentication", :conditions => {:canvas => false}
  map.facebook_root '', :controller => "fbuser", :conditions => {:canvas => true}


  #place these higher to keep a nil :id from creeping in when caught by lower ones
  # (this only happens due to my preference for having :id earlier in the URL than convention
  map.auth    'authentication/:action', :controller => 'authentication'
  map.move	  'move/:action', :controller => 'move'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:id/:action'
  map.connect ':controller/:id/:action.:format'  
  map.connect ':controller/:action'
  
end
