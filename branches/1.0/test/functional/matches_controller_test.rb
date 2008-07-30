require File.dirname(__FILE__) + '/../test_helper'

#TODO fill out the assert_select tests for this when html becomes more stable

class MatchesControllerTest < ActionController::TestCase

  ##### show action tests ##### 
  
  # the 'white on right rule' - did you know that 50% possible orientations of the board are wrong ?
  def test_renders_board_with_white_square_at_lower_right
    login_as(:dean)
    get :show, {:id => matches(:dean_vs_maria).id }
    assert_response :success
    
    assert_select "table.board tr:nth-of-type(8) td:nth-of-type(9)" do
      assert_select ".white"
    end
  end

  def test_renders_board_with_a1_in_lower_left_for_white
    login_as(:dean)
    get :show, {:id => matches(:dean_vs_maria).id }
    assert_response :success
  end

  def test_renders_board_with_h8_in_lower_left_for_black
    login_as(:maria)
    get :show, {:id => matches(:dean_vs_maria).id }
    assert_response :success
  end

  ##### index action tests ##### 
  
  def test_renders_list_of_matches_for_current_player
    login_as(:dean)
    get :index
    assert_response :success
  end

end
