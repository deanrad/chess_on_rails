require File.dirname(__FILE__) + '/../test_helper'

class MatchTest < ActiveSupport::TestCase

  # Replace this with your real tests.
  def test_player1_in_match_is_white_and_player2_is_black
    match = matches(:dean_vs_maria)
    assert_equal players(:dean), match.player1
    assert_equal players(:dean), match.white
    assert_equal players(:maria), match.black
  end

  def test_can_create_match
    assert_difference 'Match.count' do
      match = Match.new( :player1 => players(:dean), :player2 => players(:anders) )
      match.save!
      assert_equal 'dean vs. anders', match.lineup
    end
  end
  
end
