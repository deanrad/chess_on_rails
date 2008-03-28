require File.dirname(__FILE__) + '/../test_helper'

class MoveControllerTest < ActionController::TestCase
	
	# Replace this with your real tests.
	def test_truth
		assert true
	end
	
	def test_cannot_move_without_coordinates
		assert_raises ArgumentError do
			post :create, {}, {:player_id=>1}
		end
	end
	
    def test_accepts_move_with_coordinates
		post :create, {:from_coord=>"e2", :to_coord=>"e4"}, {:player_id=>1}
		assert_response 200
	end
	
    def test_uses_your_default_match_if_none_specified
		post :create, {:from_coord=>"e2", :to_coord=>"e4"}, {:player_id=>1}
		assert_response 200
		assert_equal matches(:paul_vs_dean), assigns["match"]
	end
	
	def test_uses_explicit_match_if_specified
		post :create, {:match_id=>1, :from_coord=>"e2", :to_coord=>"e4"}, {:player_id=>1}
		assert_response 200
		assert_equal matches(:dean_vs_maria), assigns["match"]
	end
	
	def test_errs_if_specified_match_not_there_or_active
		assert_raises ArgumentError do
			post :create, {:match_id=>9, :from_coord=>"e2", :to_coord=>"e4"}, {:player_id=>1}
		end
	end
	
end
