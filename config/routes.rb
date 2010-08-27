ActionController::Routing::Routes.draw do |map|

  # The priority is based upon order of creation: first created -> highest priority.

  # Default routes - facebook or not
  map.facebook_root '', :controller => "match", :conditions => {:canvas => true}
  map.root :controller => "authentication", :conditions => {:canvas => false}

  map.auth       'authentication/:action',  :controller => 'authentication'
  map.login      'authentication/login',    :controller => 'authentication', :action => 'login'
  map.logout     'authentication/logout',   :controller => 'authentication', :action => 'logout'
  map.register   'authentication/register', :controller => 'authentication', :action => 'register'

  #allow moving from CURL - Although GET generally not acceptable, post won't work without the forgery protection
  map.create_move 'match/:match_id/moves/create', :controller => 'move', :action => 'create'

  #allow this
  map.match_viewmodel 'match/:match_id/viewmodel', :controller => 'match', :action => 'viewmodel', :format => :js

  map.resources :match , :except => [:delete], :shallow => true, :collection => { :create => :post } do |match|
    match.resources :moves, :controller => :move, :collection => { :create => :post }
    match.resource :chat
  end

  #sets controller courtesy of Sean
  map.resource :set, :member => {:change => :post}

  # Install the default routes as the lowest priority.
  map.connect ':controller/:id/:action'
  map.connect ':controller/:id/:action.:format'  
  
end
