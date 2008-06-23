require File.dirname(__FILE__) + '/../test_helper'

class FbuserTest < ActiveSupport::TestCase

	def test_can_install_hitherto_unknown_user
		fb_user_id = 31415926
		assert_nil Fbuser.find_by_facebook_user_id( fb_user_id )

		fb = Fbuser.install( fb_user_id )
		assert_not_nil fb
		assert_not_nil fb.playing_as
		assert_equal "Facebook #{fb_user_id}", fb.playing_as.name
	end

	def test_can_update_name_after_signing_in
		fb_user_id = 31415926
		assert_nil Fbuser.find_by_facebook_user_id( fb_user_id )
		fb = Fbuser.install( fb_user_id )
		
		fb.name = 'Deano'
		assert_equal 'Deano', fb.reload.playing_as.name
		assert_equal 'Deano', fb.name
	end
end
