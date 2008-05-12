ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # Facebook hookup
  map.facebook_root '', :controller => "face", :conditions => {:canvas => true}

  map.match_pieces 'match/:id/pieces.xml', :controller => 'match', :action=>'pieces', :format=>'xml'
  map.match_status 'match/:id/:action.:format', :controller => 'match', :action => 'status'
  map.match_show   'match/show/:id', :controller => 'match', :action=>'show'
  map.match_resign 'match/resign/:id', :controller => 'match', :action=>'resign'
  map.match_claim_win 'match/claim_win/:id', :controller => 'match', :action=>'claim_win'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action'

  #map.match_action 'match/show/:id/:action', :controller => 'match', :format => 'html'
  #map.match_action 'match/show/:id/:action.:format', :controller => 'match'
  

  #Allow typical REST commands over match (possibly overkill)
  #map.resources :match
  
  map.root :controller => "authentication"
  
end
