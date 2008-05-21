require File.dirname(__FILE__) + '/../test_helper'

class MoveControllerTest < ActionController::TestCase
	def setup
		super
		@request.env['HTTP_REFERER'] = '/match/3/show.html' #any address will keep back error from occurring
	end	
	
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
	
      #def test_accepts_move_with_coordinates
	#	m = matches(:paul_vs_dean)
	#	assert_equal 0, m.moves.length
	#
	#	post :create, { :move=>{:from_coord => "a2", :to_coord => "a4", :match_id => m.id } }, {:player_id => m.player1.id}
	#	assert_response 302
	#end
	
	def test_errs_if_specified_match_not_there_or_active
		assert_raises ArgumentError do
			post :create, { :move=>{:match_id=>9, :from_coord=>"e2", :to_coord=>"e4"} }, {:player_id => 1}
		end
	end

  def test_cant_move_when_on_match_you_dont_own
	m = matches(:paul_vs_dean)
	assert_equal 0, m.moves.length

	assert_raises ArgumentError do
		post :create, { :move=>{:match_id=>m.id, :from_coord=>"e2", :to_coord=>"e4"} }, {:player_id => players(:maria).id }
	end
	
  end

  def test_cant_move_when_not_your_turn
	m = matches(:paul_vs_dean)
	assert_equal 0, m.moves.length

	assert_raises ArgumentError do
		post :create, { :move=>{:match_id=>m.id, :from_coord=>"e2", :to_coord=>"e4"} }, {:player_id => players(:dean).id }
	end
  end

end
