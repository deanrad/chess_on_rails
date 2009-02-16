ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Default routes - facebook or not
  map.facebook_root '', :controller => "fbuser", :conditions => {:canvas => true}
  map.root :controller => "authentication", :conditions => {:canvas => false}
  map.login   'authentication/login', :controller => 'authentication', :action => 'login'
  map.logout  'authentication/logout', :controller => 'authentication', :action => 'logout'


  map.resources :match , :except => [:delete], :shallow => true do |match|
    match.resources :moves, :controller => :move, :collection => { :create => :post }
  end

  #sets controller courtesy of Sean
  map.resource :set, :member => {:change => :post}

  # Install the default routes as the lowest priority.
  map.connect ':controller/:id/:action'
  map.connect ':controller/:id/:action.:format'  
  
end
