require File.dirname(__FILE__) + '/../test_helper'

class GameplayTest < ActionController::IntegrationTest
  fixtures :matches, :moves, :players, :users
  
  def test_navigates_from_match_listing_to_match
    login( :dean )
    assert_template 'match/index'
    get '/match/3/show'
  
    assert_response :success
    assert_template 'match/show'
  end

  def test_makes_checkmating_move
    login( :chris )
    get '/match/8/show' #scholars mate
    assert_response :success
  end

  def login( as_user )
    post 'authentication/login', {:email => users(as_user).email, :security_phrase => users(as_user).security_phrase }
    assert_response :redirect
    follow_redirect!
  
    assert_response :success
  end
end

