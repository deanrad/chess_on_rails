ChessOnRails::Application.routes.draw do
  
  root :to => 'match#index'
  
  resources :match do
    resources :moves
    resources :chats
  end

  match ':controller/:id/:action'
  match ':controller(/:action)'

  # map.login      'authentication/login',    :controller => 'authentication', :action => 'login'
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
  end
  
#   ActionController::Routing::Routes.draw do |map|
# 
#   # The priority is based upon order of creation: first created -> highest priority.
# 
#   # Default routes - facebook or not
#   map.facebook_root '', :controller => "match", :conditions => {:canvas => true}
#   map.root :controller => "authentication", :conditions => {:canvas => false}
# 
#   map.auth       'authentication/:action',  :controller => 'authentication'
#   map.login      'authentication/login',    :controller => 'authentication', :action => 'login'
#   map.logout     'authentication/logout',   :controller => 'authentication', :action => 'logout'
#   map.register   'authentication/register', :controller => 'authentication', :action => 'register'
# 
#   #allow moving from CURL - Although GET generally not acceptable, post won't work without the forgery protection
#   map.create_move 'match/:match_id/moves/create', :controller => 'move', :action => 'create'
# 
#   map.match_players 'match/players.js', :controller => 'match', :action => 'players'
# 
#   map.resources :match , :except => [:delete], :shallow => true, :collection => { :create => :post } do |match|
#     match.resources :moves, :controller => :move, :collection => { :create => :post }
#     match.resource :chat
#   end
# 
# 
#   #sets controller courtesy of Sean
#   map.resource :set, :member => {:change => :post}
# 
#   # Install the default routes as the lowest priority.
#   map.connect ':controller/:id/:action'
#   map.connect ':controller/:id/:action.:format'  
#   
# end
