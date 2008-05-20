ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Default routes - facebook or not
  map.root :controller => "authentication", :conditions => {:canvas => false}
  map.facebook_root '', :controller => "fbuser", :conditions => {:canvas => true}


  map.auth    'authentication/:action', :controller => 'authentication'
  map.move	  'move/:action', :controller => 'move'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:id/:action'
  map.connect ':controller/:id/:action.:format'  
  
end
