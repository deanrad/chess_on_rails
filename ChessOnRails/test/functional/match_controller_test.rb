require File.dirname(__FILE__) + '/../test_helper'

class MatchControllerTest < ActionController::TestCase

  def test_shows_a_match_from_the_correct_side
  	assert true #todo fill this out with what it *means* to see a match from the correct side
  end
  
  #the xml version of match/id/pieces returns detailed data about piece position, allowed moves, etc..
  def test_returns_xml_doc_of_pieces_when_asked_for_it
	get :pieces, { :format => "xml", :id => 3 }, {:player_id=>1}
  	assert_select "pieces"
  end

  #the html version of match/id/pieces returns a board with pieces laid out in it, nothing more
  def test_returns_html_doc_of_pieces_in_board_when_asked
	get :pieces, { :format => "html", :id => 3 }, {:player_id=>1}
  	assert_select "table[id='board_table']"
  end
  	
end
