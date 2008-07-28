require File.dirname(__FILE__) + '/../test_helper'

class MatchControllerTest < ActionController::TestCase

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

  def test_verifies_showing_a_match_renders_the_board
    get :show, { :id => 9 }, {:player_id => players(:dean).id }
    assert_response 200
    assert_select 'div#board_table'
  end

end
