ActionController::Routing::Routes.draw do |map|

  #restful_authentication routes
  map.resources :players
  map.resource :session

  #our application routes  
  map.resources :matches do |match|
    match.resources :moves
  end


end
