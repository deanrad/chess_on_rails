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
#
# A piece will know its theoretical moves - where it could move on an empty board- but this 
# will be filtered by the board in order to preclude certain things like moving on to a piece
# of your own color, or leaving or placing your king in check
class Piece 
  ROLES = [:king, :queen, :bishop, :knight, :rook, :pawn ]
  FLANKS = [:kings, :queens]
  WHICH = [:a, :b, :c, :d, :e, :f, :g, :h, :promoted] + FLANKS
  ROLES_WITH_MANY = [:bishop, :knight, :rook, :pawn]
  MINOR_PIECES = [:bishop, :knight, :rook]
  
  SIDE_PIECES = [:a_pawn, :b_pawn, :c_pawn, :d_pawn, :e_pawn, :f_pawn, :g_pawn, :h_pawn,
                 :queens_rook, :queens_knight, :queens_bishop, :queen, 
                 :king, :kings_bishop, :kings_knight, :kings_rook ]
    
  DIAGONAL_MOTIONS =  [[1,1], [1,-1], [-1,1], [-1,-1]]
  STRAIGHT_MOTIONS =  [[1,0], [-1,0], [ 0,1],  [0,-1]]
  KNIGHT_MOVES     =  [[1,2], [1,-2], [-1,2], [-1,-2], [2,1], [2,-1], [-2,1], [-2,-1] ]
  
  attr_reader :role, :side, :which
  attr_reader :lines_of_attack
  attr_reader :direct_moves

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
  
  # Creates a piece knowing at least its role and side, and program its possible moves
  def initialize(role, side, which=nil)
    @role = role 
    @side = side
    @which = which 
    
    #setup lines of attack
    @lines_of_attack ||= []
    
    #bishops and queens can move in diagonals with no limits
    if (@role == :bishop or @role==:queen)
      DIAGONAL_MOTIONS.each{ |move| @lines_of_attack << LineOfAttack.new(move) }
    end
    
    #rooks move straight, and queens get these lines of attack as well
    if (@role == :rook or @role==:queen)
      STRAIGHT_MOTIONS.each{ |move| @lines_of_attack << LineOfAttack.new(move) }
    end
    
    #the superset of possible pawn moves include forward 1 and 2, and diagonal single-steps
    if (@role==:pawn)
      #figure out which way is forward
      forward = Sides[@side].advance_direction
      
      #a short line-of-attack in the forward direction
      @lines_of_attack << LineOfAttack.new( [forward, 0] , 2 ) 
      
      #and the diagonal forward moves
      [1,-1].each{ |diag| @lines_of_attack << LineOfAttack.new( [forward, diag], 1 ) }
    end
    
    if (@role == :king)
      DIAGONAL_MOTIONS.each{ |move| @lines_of_attack << LineOfAttack.new(move, 1) }      
      STRAIGHT_MOTIONS.each{ |move| @lines_of_attack << LineOfAttack.new(move, 1) }      
      
      #castling, king and queenside respectively works like a line of attack
      # in that no piece may lie between you and that square
      @lines_of_attack << LineOfAttack.new( [0, 2], 1) 
      @lines_of_attack << LineOfAttack.new( [0,-3], 1) 
    end 
    
    #knights have no lines of attack - but they have direct moves
    @direct_moves = (@role == :knight) ? KNIGHT_MOVES : []
  end

  
end

class AmbiguousPieceError < Exception
end