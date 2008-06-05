require File.dirname(__FILE__) + '/../test_helper'

class GameplayTest < ActionController::IntegrationTest
  fixtures :matches, :moves, :players, :users
	
  def test_navigates_from_match_listing_to_match
	post 'authentication/login', {:email => users(:dean).email, :security_phrase => users(:dean).security_phrase }
	assert_response :redirect
	follow_redirect!

	#get '/match/'
	assert_response :success
	assert_template 'match/index'

	get '/match/3/show'
	assert_response :success
	assert_template 'match/show'
  end

end

