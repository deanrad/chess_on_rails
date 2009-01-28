#The fields our AR objects need, not yet auto-generated
class Move
  attr_accessor :castled
  attr_accessor :promotion_piece
  attr_accessor :notation
  attr_accessor :capture_coord
end

class Match
  attr_accessor :active
  def active() @active != false end  #starts active
end
class Player
  attr_accessor :login
end

#mix our fixtures in so they're available in all tests
class Spec::Example::ExampleGroup
  include ::ChessFixtures
  
  #TODO get rid of create_move_against_match_with_board silly helper
  def create_move_against_match_with_board m, b, coords
    m.board = b
    Move.new coords
  end
end

