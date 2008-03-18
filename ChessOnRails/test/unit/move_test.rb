require File.dirname(__FILE__) + '/../test_helper'

class MoveTest < ActiveSupport::TestCase
	# Replace this with your real tests.
	def test_truth
		assert true
	end
	
	def test_match1_has_2_moves
		m1 = matches(:dean_vs_maria)
		assert_equal 2, m1.moves.count
	end
	
	def test_unstarted_match_has_no_moves
		m1 = matches(:unstarted_match)
		assert_equal 0, m1.moves.count
	end
	
	def test_match_has_moves_in_proper_order
		m1 = matches(:dean_vs_maria)
		assert_equal 2, m1.moves.count
		assert_equal players(:dean), m1.moves[0].player
		assert_equal players(:maria), m1.moves[1].player
	end
	
	def test_can_play_first_two_moves_correctly
		m1 = matches(:unstarted_match)	  
		
		m1.moves << Move.new( :from_coord=>"e2", :to_coord=>"e4", :notation=>"e4", :moved_by=>1 )
		m1.moves << Move.new( :from_coord=>"d7", :to_coord=>"d5", :notation=>"d5", :moved_by=>2 )
		
		assert m1.valid?
		assert m1.save!
	end

	#really a test of match validation
	def test_cannot_move_twice_by_same_player
		m1 = matches(:dean_vs_maria)
		
		assert_equal 2, m1.moves.count
		assert_equal 1, m1.moves[0].moved_by
		assert_equal 2, m1.moves[1].moved_by
		assert m1.valid?
		
		m3 = Move.new( :from_coord=>"d7", :to_coord=>"d5", :notation=>"d5", :moved_by=>2 )
		m1.moves << m3
		
		#assure its in the third position, or consecutive move detection could be broken
		assert_equal m3, m1.moves[2] 

		assert !m1.valid?
	end
end
