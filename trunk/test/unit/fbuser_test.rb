require File.dirname(__FILE__) + '/../test_helper'

class FbuserTest < ActiveSupport::TestCase

	def test_can_update_name_after_signing_in
		fb = Fbuser.find_by_facebook_user_id( fbusers(:dean).facebook_user_id )
		
		fb.name = 'Deanoxyz'
		assert_equal 'Deanoxyz', fb.reload.playing_as.name
		assert_equal 'Deanoxyz', fb.name
	end
end
