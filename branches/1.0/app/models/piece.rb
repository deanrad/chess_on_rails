# A Piece is a transient object, not stored in the database, but inferred, queried, used
# and disposed as needed for the purpose of validating +moves+ and implementing gameplay
#
# All piece types are instance of the same class +Piece+, and include types described at:
# http://en.wikipedia.org/wiki/Chess
#
# There are varying levels of specificity when describing a +Piece+
# board_id::  unique to any piece on board - +white_kings_rook+, +black_a_pawn+, +black_queen+
# side_id::   unique to any piece on one side - +kings_rook+, +queen+
# role::      which set of rules apply to this piece - +rook+, +bishop+, +pawn+
# side::     +white+, +black+
# flank::     +kings+, +queens+
# which::     +a+, +kings+  (in other words, the +flank+ for minor pieces, the file for pawns)
class Piece 
  ROLES = [:king, :queen, :bishop, :knight, :rook, :pawn ]
  FLANKS = [:kings, :queens]
  WHICH = [:a, :b, :c, :d, :e, :f, :g, :h, :promoted] + FLANKS
  ROLES_WITH_MANY = [:bishop, :knight, :rook, :pawn]
  
  SIDE_PIECES = [:a_pawn, :b_pawn, :c_pawn, :d_pawn, :e_pawn, :f_pawn, :g_pawn, :h_pawn,
                 :queens_rook, :queens_knight, :queens_bishop, :queen, 
                 :king, :kings_bishop, :kings_knight, :kings_rook ]
  
  #intern these symbols at class load time
#  symbolize_each_combo_of Match::SIDES, Piece::SIDE_PIECES
  
  attr_accessor :role, :side, :which

  # A unique one of white's pieces, for instance
  def side_id
    if ROLES_WITH_MANY.include?(@role)
      raise AmbiguousPieceError unless @which
      "#{@which}_#{@role}".to_sym 
    else
      "#{@role}".to_sym
    end
  end

  # A unique piece across the whole board
  def board_id
    raise AmbiguousPieceError unless @side
    "#{@side}_#{side_id}".to_sym
  end      
  
  # Creates a piece knowing at least its role
  def initialize(role, side=nil, which=nil)
    @role = role 
    @side = side
    @which = which 
  end

end

class AmbiguousPieceError < Exception
end