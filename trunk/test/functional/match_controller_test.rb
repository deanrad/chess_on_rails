require File.dirname(__FILE__) + '/../test_helper'

class MatchControllerTest < ActionController::TestCase

  def test_shows_a_match_from_the_correct_side
  	assert true #todo fill this out with what it *means* to see a match from the correct side
  end
  
  #the xml version of match/id/pieces returns detailed data about piece position, allowed moves, etc..
  def test_returns_xml_doc_of_pieces_when_asked_for_it
	get :pieces, { :format => "xml", :id => 3 }, {:player_id => 1}
  	assert_select "pieces"
  end

  #the html version of match/id/pieces returns a board with pieces laid out in it, nothing more
  def test_returns_html_doc_of_pieces_in_board_when_asked
	get :pieces, { :format => "html", :id => 3 }, {:player_id => 1}
  	assert_select "table[id='board_table']"
  end

  def test_lets_you_know_when_its_your_turn(ajax,_not_thru_facebook)
	#assert true
  end
  	
  def test_redirected_to_match_listing_page_when_resigning_match
	get :resign, { :format => 'html', :id => 2}, {:player_id => 1}
	assert_response 302
  end 

  def test_white_view_of_board_when_requested_by_white
      get :show, { :id => matches(:paul_vs_dean).id }, {:player_id => players(:paul).id }
      assert_response 200
      assert_equal :white, assigns['viewed_from_side']

	#assert 8 is first in the list so when board rendered down page, 1 is at the bottom
      assert_equal '8', assigns['ranks'][0].chr 
  end

  def test_black_view_of_board_when_requested_by_black
      get :show, { :id => matches(:paul_vs_dean).id }, {:player_id => players(:dean).id }

      assert_response 200
      assert_equal :black, assigns['viewed_from_side']

      assert_equal '1', assigns['ranks'][0].chr 
  end

  def test_requesting_ended_match_yields_result_template
	get :show, { :id => matches(:resigned).id }, {:player_id => players(:dean).id }
      assert_response 200
      assert_template 'match/result'
  end

  def test_gets_form_for_creating_new_match
	get :new, nil, {:player_id => players(:dean).id }
	assert_response 200
	assert_template 'match/new'
  end

  def test_creates_new_match_opponent_as_black
      post :create, {:opponent_side => 2, :opponent_id => players(:paul).id}, {:player_id => players(:dean).id }
	assert_not_nil assigns['match']
	assert_response 302
  end

  def test_gets_match_status
	get :status, { :id => matches(:paul_vs_dean).id}, {:player_id => players(:paul).id }
	assert_response 200
  end 

  def test_gets_list_of_active_matches
	get :index, nil, {:player_id => players(:paul).id }
      assert_equal [], assigns['matches'].find { |m| m.id == matches(:resigned).id }
	assert_response 200
  end

  def test_notates_basic_move
	get :notate_move, { :move=>{ :match_id => matches(:dean_vs_maria), :from_coord => 'd2', :to_coord => 'd4' } }, {:player_id => players(:dean).id}
	assert_response 200
  end	

end
