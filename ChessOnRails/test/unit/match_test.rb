require File.dirname(__FILE__) + '/../test_helper'

class MatchTest < ActiveSupport::TestCase
	# Replace this with your real tests.
	def test_truth
		assert true
	end
	
	def test_nodoc_finds_fixture1
		m1 = matches(:dean_vs_maria)
		assert_not_nil m1
		assert_equal players(:dean), m1.player1
		assert_equal players(:maria), m1.player2
		assert_equal 1, m1.player1.id
		assert_equal "Maria", m1.player2.name
	end
	
	def test_nodoc_finds_fixture2
		m1 = matches(:paul_vs_dean)
		assert_not_nil m1
		assert_equal "Paul", m1.player1.name
		assert_equal "Dean", m1.player2.name
	end
	
	def test_returns_active_matches
		matches=[]
		d = players(:dean)
		assert_equal 2, d.active_matches.count
		assert_equal 2, d.matches.count
	end
	
    def test_knows_what_side_player_is_on
		m1 = matches(:paul_vs_dean)
		assert_equal players(:paul).id, m1.player1.id
		assert_equal players(:dean).id, m1.player2.id
		
		puts "Paul on " + m1.side_of( players(:paul) ).to_s
		puts "Dean on " + m1.side_of( players(:dean) ).to_s
		
		assert_equal :white, m1.side_of( players(:paul) )
		assert_equal :black, m1.side_of( players(:dean) )
		
	end
end
