require File.dirname(__FILE__) + '/../test_helper'

class FbuserControllerTest < ActionController::TestCase

	def test_facebook_request_is_good_as_authenticated

		get :index, { :fb_sig_user => '829567899' }
		assert_equal Player.find(1), assigns['current_player']
	end

end
