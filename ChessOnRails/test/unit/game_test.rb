require File.dirname(__FILE__) + '/../test_helper'

class GameTest < ActiveSupport::TestCase
	# Replace this with your real tests.
	def test_truth
		assert true
	end
	def test_chess_pieces_singleton
		#due to singletonian nature of Chess.initial_pieces, repeated
		# calls for those pieces should be returning 
		ip1 = Chess.initial_pieces
		ip2 = Chess.initial_pieces
		assert_same ip1, ip2, "Chess.initial_pieces returned multiple instances of the piece array - possible memory leak."
	end
	def test_chess_pieces_number_32
                assert_equal 32, Chess.initial_pieces
	end
end
