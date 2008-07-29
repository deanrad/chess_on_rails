require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  
  def test_truth
    assert true
  end
  
  #region Fixture Tests
  def test_nodoc_user1_finds_player1_fixture_instantiation
    u1 = users(:dean)
    assert_equal "Dean", u1.playing_as.name
  end
  
  def test_nodoc_user1_finds_player1_find_by
    u1 = User.find_by_email "chicagogrooves@gmail.com"
    assert_equal "Dean", u1.playing_as.name
    assert_equal 1, u1.playing_as.id
  end
  #endregion
end
