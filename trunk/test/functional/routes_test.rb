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

  #def test_generates_url_for_move_creation
  #  opts = {:controller=>"move", :move=>{:match_id=>3, :from_coord=>"e2", :notation=>"e4", :to_coord=>"e4"}, :action=>"create"} 
  #  url = '/match/6/moves'
  #  assert_equal opts, rs.recognize_path(url)
  #end

  def test_resignation_url_includes_id
    assert_equal( '/match/6/resign' , rs.generate( { :controller => 'match', :id => '6', :action => 'resign'} ) )
  end

  def test_recognizes_fbuser_register_url
    assert_equal( {:controller => 'fbuser', :action => 'register'} , rs.recognize_path("/fbuser/register") )
  end

  def test_moves_for_match_exposed_resource_style
    opts = { :controller => "move", :action => "index", :match_id => '6'  }
    url = '/match/6/moves'
    #assert_routing    url , opts
    #assert_recognizes opts, url
    assert_equal( opts, rs.recognize_path(url) )
  end

  def test_can_post_move_to_match_moves_with_specifying_side
    assert_equal( 
      {:controller => 'move', :action => 'create', :match_id => '6', :side => 'black'}, rs.recognize_path("/match/6/moves/black", :method => :post)
    )
  end

  def test_can_post_move_to_match_moves_omitting_side
    assert_equal( 
      {:controller => 'move', :action => 'create', :match_id => '6' }, rs.recognize_path("/match/6/moves/", :method => :post)
    )
  end

end
