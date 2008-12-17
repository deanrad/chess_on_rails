ActionController::Routing::Routes.draw do |map|

  #restful_authentication routes
  map.resources :players
  map.resource :session

  #our application routes  
  map.resources :matches do |match|
    match.resources :moves
  end

  #when client requests board_refresh_url, they get a refresh if the move number
  #they send is not the latest.
  map.board_refresh '/matches/:match_id/move_:move_num_or_latest',  :controller => 'moves',
                                                                    :action => 'refresh'

end
