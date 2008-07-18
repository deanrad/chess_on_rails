require File.dirname(__FILE__) + '/../test_helper'

class FbuserControllerTest < ActionController::TestCase

  def test_can_sniff_facebook_request_test_or_actual

    get :index, { :fb_sig_user => fbusers(:dean).facebook_user_id }
    assert_equal fbusers(:dean).facebook_user_id, session[:facebook_user_id]
    assert_equal players(:dean).id , session[:player_id]
    
  end

  def test_does_not_authenticate_without_facebook_info
    get :index, { :fb_sig_user => '' }

    assert_nil session[:facebook_user_id]
    assert_nil assigns[:current_player]
  end

  def test_redirected_to_login_to_facebook_when_requested_in_TEST_environment_and_unauthenticated
    get :index
    assert_response 302
    assert_equal true, @response.redirected_to.include?( 'facebook.com/login' )
  end

  def test_known_fbuser_can_invoke_register_to_set_new_name
    post :register, { :name => 'New name', :fb_sig_user => fbusers(:dean).facebook_user_id }
    assert_response 302
    assert_equal 'New name', fbusers(:dean).reload.name
  end

  def test_unknown_fbuser_can_invoke_register_to_establish_self_with_new_name
    unknown_id = fbusers(:dean).facebook_user_id + 1

    assert_nil Fbuser.find_by_facebook_user_id( unknown_id )

    post :register, { :name => 'Newer name', :fb_sig_user => unknown_id }

    #now we have them
    assert_not_nil fbuser = Fbuser.find_by_facebook_user_id( unknown_id )

    #have recorded their name
    assert_equal 'Newer name', fbuser.name

    #and sent them on their way
    assert_response 302
  end

  def test_newly_registered_user_gets_a_match_with_me
    unknown_id = fbusers(:dean).facebook_user_id + 1

    assert_nil Fbuser.find_by_facebook_user_id( unknown_id )

    get :index    , { :fb_sig_user => unknown_id }
    post :register, { :name => 'Newer name', :fb_sig_user => unknown_id }
    assert_equal 1, Fbuser.find_by_facebook_user_id( unknown_id ).playing_as.active_matches.count
  end
end
