require File.dirname(__FILE__) + '/../test_helper'

class MoveControllerTest < ActionController::TestCase
	
	
	def test_reject_move_made_without_coordinates
		assert_raises ArgumentError do
			post :create, {}, {:player_id=>1}
		end
	end

	def test_reject_move_made_with_one_or_more_invalid_coordinates
		assert_raises ArgumentError do
			post :create, {:move=>{ :from_coord => "e2", :to_coord => "x9", :match_id => 3 } }, {:player_id => 1}
		end
	end
	
      def test_accepts_move_with_coordinates
		@request.env['HTTP_REFERER'] = '/match/6/show.html'
		post :create, { :move=>{:from_coord => "a2", :to_coord => "a4", :match_id => 3, :moved_by => 1} }, {:player_id => 1}
		assert_response 302
	end
	
	def test_errs_if_specified_match_not_there_or_active
		assert_raises ArgumentError do
			post :create, { :move=>{:match_id=>9, :from_coord=>"e2", :to_coord=>"e4"} }, {:player_id => 1}
		end
	end

end
