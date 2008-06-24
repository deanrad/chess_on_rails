require File.dirname(__FILE__) + '/../test_helper'

class RoutesTest < ActionController::TestCase
	attr_accessor :rs
	def setup
		#use this approach to source in the actual routes file
		@rs = ActionController::Routing::Routes
		load 'config/routes.rb'

		#use this approach to test the set of routes in this file
		#@rs = ActionController::Routing::RouteSet.new
		#@rs.draw do |map|
		#	map.connect ':controller/:id/:action' 
		#	map.connect ':controller/:id/:action.:format'
		#end
		
	end

	def test_authentication_url_is_authentication_slash_login
		assert_equal( '/authentication/login', rs.generate( {:controller => 'authentication', :action => 'login' } ) )
	end

	def test_redirection_to_login_is_autentication_controller_login_action
		assert_equal( {:controller => 'authentication', :action => 'login'} , rs.recognize_path("/authentication/login") )
	end

	def test_routes_match_display_without_format
		assert_equal( {:controller => 'match', :action => 'show', :id => '6'}, rs.recognize_path("/match/6/show") )
	end

	def test_routes_match_display_with_format
		assert_equal( {:controller => 'match', :action => 'show', :id => '6', :format => 'html'}, rs.recognize_path("/match/6/show.html") )
	end
	
	def test_generates_relative_url_for_match_status
		assert_equal( '/match/6/status' , rs.generate( { :controller => 'match', :id => '6', :action => 'status'} ) )
	end

	def test_generates_relative_url_for_move_notation
		assert_equal( '/move/notate' , rs.generate( { :controller => 'move', :action => 'notate'} ) )
	end

	def test_resignation_url_includes_id
		assert_equal( '/match/6/resign' , rs.generate( { :controller => 'match', :id => '6', :action => 'resign'} ) )
	end

	def test_recognizes_fbuser_register_url
		assert_equal( {:controller => 'fbuser', :action => 'register'} , rs.recognize_path("/fbuser/register") )
	end
end
