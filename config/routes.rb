ActionController::Routing::Routes.draw do |map|

  #restful_authentication routes
  map.resources :players
  map.resource :session
  map.resource :set, :member => {:change => :post}

  #our application routes  
  map.resources :matches do |match|
    match.resources :moves
    match.resources :chats
  end

end
