require File.dirname(__FILE__) + '/../test_helper'

class AuthenticationControllerTest < ActionController::TestCase
	
	def test_truth
		assert true
	end
	
	def test_only_logged_in_can_change_security_question
		get :change_security_question
		assert_response 302
		
		#in first hash are http params, in second hash are session params
		get :change_security_question, {}, {:player_id => 2}
		assert_response 200
	end
	
	#not technically a controller test
	def test_login_security_question_only
		dean = User.find_by_email_and_security_phrase( 'chicagogrooves@gmail.com', '9' )
		dean2 = users(:dean)
		
		assert_not_nil dean
		assert_equal dean, dean2
	end
	
	def test_test_user_dean_can_login
		post :login, :email => 'chicagogrooves@gmail.com', :security_phrase => '9'
		
		assert_equal 1, session[:player_id]
		assert_not_nil assigns(:player)
	end
	
	def test_user_can_login
		post :login, :email => 'maria_poulos@yahoo.com', :security_phrase => '3'
		
		assert_equal 2, session[:player_id]
		assert_not_nil assigns(:player)
	end

	def test_user_can_logout

		post :login, :email => 'maria_poulos@yahoo.com', :security_phrase => '3'

		assert_equal 2, session[:player_id]
		assert_not_nil assigns(:player)

		post :logout
		assert_nil session[:player_id]
	end

	def test_redirects_to_uri_first_requested_after_login
		uri = '/match/6/show'
		post :login, {:email => 'chicagogrooves@gmail.com', :security_phrase => '9'}, { :original_uri => uri }
		assert_response 302
		assert @response.headers['Location'].include?( uri )
	end
	
	def test_reject_incorrect_login
		post :login, :email => 'chicagogrooves@gmail.com', :security_phrase => 'nowaynoway'
		assert_response :success
		assert_nil session[:player_id]
		assert_nil assigns(:player)
		assert_equal 'Your credentials do not check out.', flash[:notice]				
	end

	#helper functions		
	def in_controller(new_controller)
		old_controller = @controller
		@controller = new_controller.new
		yield
		@controller = old_controller
	end
end
