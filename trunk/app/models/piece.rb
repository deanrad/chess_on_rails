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
# A piece will know its desired moves - where it could move on an empty board- but this 
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
  
  #Desired_moves_from_here is what you see in a guide to playing chess- the way you first instruct
  # somebody how a piece moves, in other words, what is possible with no special circumstances considered
  # It is customized by overriding vector_allowed_from in specific piece's class to, for example, instruct
  # that a pawn may only move 2 from a given position. It is also filtered by the board later, but this 
  # is just how the piece WANTS to move, if it were not impeded by outside rules :)
  def desired_moves_from(here)
    move_vectors = []
    @lines_of_attack.each do |line|
      line.each  { |vector| move_vectors << vector if vector_allowed_from(here, vector) }
    end
    @direct_moves.each { |vector| move_vectors << vector }
    return move_vectors.select { |move| (Position.new(here) + move).valid? }
  end
  
  #a pawn or king overrides this to veto certain moves depending on where it is
  def vector_allowed_from(from_position, vector, board = nil)
    true
  end
  
  #on a given board returns those moves not impeded by other pieces
  def unblocked_moves(from_position, board)
    move_vectors = []
    @lines_of_attack.each do |line|
      has_encountered_piece = false
      
      line.each do |move_vector| 
        break if has_encountered_piece
        
        new_position = Position.new(from_position) + move_vector
        break unless new_position.valid?
        
        piece_moved_upon = board[new_position]
        if( piece_moved_upon )
          has_encountered_piece = true
          if vector_allowed_from(from_position, move_vector, board) and piece_moved_upon.side != self.side
            move_vectors << move_vector 
          end
        else
          move_vectors << move_vector if vector_allowed_from(from_position, move_vector, board) 
        end
      end
    end
    
    @direct_moves.each do |move_vector| 
      new_position = Position.new(from_position) + move_vector
      next unless new_position.valid?
      
      piece_moved_upon = board[new_position]
      if piece_moved_upon == nil or piece_moved_upon.side != self.side
        move_vectors << move_vector 
      end
    end
    move_vectors
  end
  
  # Creates a piece knowing at least its role and side, and program its possible moves
  def initialize(role, side, which=nil)
    @role = role 
    @side = side
    @which = which 
    
    #setup lines of attack
    @lines_of_attack = []
    @direct_moves = []
  end

  
end

class AmbiguousPieceError < Exception
end