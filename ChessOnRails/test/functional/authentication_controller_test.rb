require File.dirname(__FILE__) + '/../test_helper'

class AuthenticationControllerTest < ActionController::TestCase
	
	def test_truth
		assert true
	end
	
	#You can request or GET methods from controllers which, mind you don't neccessarily
	# run in a web server environment, but indicate success and failure similarly to 
	# HTTP error codes , for developer convenience !
	def test_have_index_login_logout_actions
		
		[:index, :login, :logout].each do |action|
			get action
			assert_response :success, "Failure on #{action} action"
		end
	end
	
	def test_only_logged_in_can_change_security_question
		get :change_security_question
		assert_response 302
		
		#in first hash are http params, in second hash are session params
		get :change_security_question, {}, {:player_id=>2}
		assert_response 200
	end
	
	#not technically a controller test
	def test_login_security_question_only
		dean = User.find_by_email_and_security_phrase "chicagogrooves@gmail.com", "9"
		dean2 = users(:dean)
		
		assert_not_nil dean
		assert_equal dean, dean2
	end
	
	def test_test_user_dean_can_login
		post :login, :email=>"chicagogrooves@gmail.com", :security_phrase=>"9"
		
		assert_equal 1, session[:player_id]
		assert_not_nil assigns(:player)
		assert_equal "You are logged in.", flash[:notice]
	end
	
	def test_test_user_maria_can_login
		post :login, :email=>"maria_poulos@yahoo.com"
		assert_response :success
		
		assert_equal 2, session[:player_id]
		assert_not_nil assigns(:player)
	end
	
	def test_reject_incorrect_login
		post :login, :email=>"chicagogrooves@gmail.com", :security_phrase=>"nowaynoway"
		assert_response :success
		assert_nil session[:player_id]
		assert_nil assigns(:player)
		assert_equal "Your credentials do not check out.", flash[:notice]				
	end
	
	def test_reject_move_without_login
		in_move_controller do
			post :create
			assert_response 302
		end
	end
	
	#region Helper functions
	#I love this little idiomatic function that will execute the block passed to it
	# on a different controller by swapping it for the duration of the code execution.
	# note the little yield statement, during which the passed block is executed
	def in_move_controller(new_controller = MoveController)
		old_controller = @controller
		@controller = new_controller.new
		yield
		@controller = old_controller
	end
	#endregion
end
