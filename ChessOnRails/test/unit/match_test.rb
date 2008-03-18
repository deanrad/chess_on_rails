require File.dirname(__FILE__) + '/../test_helper'

class MatchTest < ActiveSupport::TestCase
	# Replace this with your real tests.
	def test_truth
		assert true
	end
	
	def test_finds_fixture1
		m1 = matches(:dean_vs_maria)
		assert_not_nil m1
		assert_equal players(:dean), m1.player1
		assert_equal players(:maria), m1.player2
		assert_equal 1, m1.player1.id
		assert_equal "Maria", m1.player2.name
	end
	
	def test_finds_fixture2
		m1 = matches(:paul_vs_dean)
		assert_not_nil m1
		assert_equal "Paul", m1.player1.name
		assert_equal "Dean", m1.player2.name
	end
	
	def test_noone_to_move_defaults_to_player1
		m1 = matches(:dean_vs_maria)
		
		assert_equal players(:dean), m1.next_to_move
	end
	
end