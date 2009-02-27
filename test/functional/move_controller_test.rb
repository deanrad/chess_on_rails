require File.dirname(__FILE__) + '/../test_helper'

class MoveControllerTest < ActionController::TestCase

  def setup
    super
    @request.env['HTTP_REFERER'] = '/match/3/show.html' #any address will keep back error from occurring
  end	
  
  #todo - this, like other gameplay methods should not raise exceptions out of the controller
  def test_reject_move_made_with_one_or_more_invalid_coordinates
    post :create, {:match_id => 3, :move => { :from_coord =>'e2', :to_coord => 'x9' }  }, {:player_id => 1}
    assert_not_nil flash[:move_error]
  end
  
  def test_accepts_and_notates_move_via_coordinates
    m = matches(:paul_vs_dean)
    
    assert_equal 0, m.moves.length
  
    post :create, { :match_id => m.id, :move => {:from_coord => 'a2', :to_coord => 'a4'} }, {:player_id => m.player1.id}
    assert_response 302
    assert_nil flash[:move_error]

    assert_equal 1, m.reload.moves.length
    assert_not_nil m.moves.last.notation
  end
  
  def test_errs_if_specified_match_not_there_or_active
    post :create, { :match_id => 9, :move => {:from_coord => 'e2', :to_coord => 'e4'} }, {:player_id => 1}
    assert_not_nil flash[:move_error]
  end

  def test_cant_move_when_on_match_you_dont_own
    m = matches(:paul_vs_dean)
    assert_equal 0, m.moves.length

    post :create, { :match_id => m.id, :move => {:from_coord => 'e2', :to_coord => 'e4'} }, {:player_id => players(:maria).id }
    assert_not_nil flash[:move_error]
  end

  def test_reject_move_made_with_notation_and_one_or_more_coordinates
    post :create, {:match_id => 3, :move => { :from_coord => 'e2', :to_coord => 'e4', :notation => 'e4' } }, {:player_id => 1}
    assert_not_nil flash[:move_error]
  end

  def test_reject_move_made_without_notation_or_coordinates
    post :create, { :match_id => 3 }, {:player_id => 1}
    assert_not_nil flash[:move_error]
  end

  def test_cant_move_when_not_your_turn
    m = matches(:paul_vs_dean)
    assert_equal 0, m.moves.length

    post :create, { :match_id => m.id, :move => {:from_coord=>'e2', :to_coord=>'e4'} }, {:player_id => players(:dean).id }
    assert_not_nil flash[:move_error]
  end

  def test_game_over_when_checkmating_move_posted
    m = matches(:scholars_mate)	

    post :create, { :match_id => m.id, :move => { :notation => 'Qf7' } }, {:player_id => players(:chris).id }		

    assert_not_nil   m.reload.winning_player
    assert_not_equal 1, m.active
  end

  def test_non_ajax_move_posting_redirects_to_match_page
    m = matches(:paul_vs_dean)
    post :create, { :match_id => m.id, :move => {:from_coord => 'e2', :to_coord => 'e4'} }, {:player_id => players(:paul).id }
    assert_response :redirect		
  end

  def test_ajax_move_responds_with_rjs_template_to_update_status
    m = matches(:paul_vs_dean)
    xhr :post, :create, { :match_id => m.id, :move => {:from_coord => 'e2', :to_coord => 'e4'} }, {:player_id => players(:paul).id }
    assert_template 'match/status'
    assert_response :success
  end

  def test_invalid_ajax_move_responds_with_error
    m = matches(:paul_vs_dean)
    xhr :post, :create, { :match_id => m.id, :move => {:from_coord => 'e4', :to_coord => 'e6'} }, {:player_id => players(:paul).id }
    assert_template 'match/status'
    assert_not_nil flash[:move_error]
  end

  def test_can_request_move_list_for_match
    get :index, { :match_id => matches(:paul_vs_dean).id }, {:player_id => players(:paul).id }
    assert_response :success
    assert_nil flash[:move_error]
  end
  
end
