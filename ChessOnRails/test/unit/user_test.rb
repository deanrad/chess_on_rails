require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
		
	# Replace this with your real tests.
	def test_truth
		assert true
	end
	
	#region Fixture Tests
	def test_user1_finds_player1_fixture_instantiation
		u1 = users(:dean)
		assert_equal "Dean", u1.playing_as.name
	end
	def test_user1_finds_player1_find_by
		u1 = User.find_by_email "chicagogrooves@gmail.com"
		assert_equal "Dean", u1.playing_as.name
		assert_equal 1, u1.playing_as.id
		
		p1= u1.playing_as
		puts "#{p1.name}'s record is: #{p1.win_loss}"
	end
	#endregion
end
