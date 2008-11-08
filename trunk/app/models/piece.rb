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
  
  #TODO it bugs me that lines_of_attack is instance data on pieces, which instead can be a lookup by role/side
  attr_reader :lines_of_attack
  attr_reader :direct_moves

  # A unique one of white's pieces, for instance. To differentiate pawns from each other
  # The which parameter is appended, but this is not needed for unique pieces on a side like king
  def side_id
    if @which
      "#{@which}_#{@role}".to_sym 
    else
      "#{@role}".to_sym
    end
  end
  
  # A unique piece across the whole board
  def board_id
    "#{@side}_#{side_id}".to_sym
  end      
  
  def abbrev
    Piece.role_to_abbrev( @role )
  end
  
  #Desired_moves_from (here) gives you what you get in a guide to playing chess, and how you first instruct
  # somebody how a piece moves, in other words, what is possible with no special circumstances considered.
  # It is customized by overriding vector_allowed_from in specific piece's class to, for example, instruct
  # that a pawn may only move 2 from a given position. It is also filtered by the board later, but first 
  # Desired_moves_from describes how the piece WANTS to move, if it were not impeded by outside rules :)
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
      move_vectors += unblocked_moves_on_line(line, from_position, board)
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
  
  def unblocked_moves_on_line(line, from_position, board)
      moves = []
      line.each do |move_vector| 
        
        new_position = Position.new(from_position) + move_vector
        return moves unless new_position.valid?
        
        piece_moved_upon = board[new_position]
        
        #if you find a piece you either append this position and return, or simply return
        # depending on whether you can make a capture on that square
        if( piece_moved_upon )
          if vector_allowed_from(from_position, move_vector, board) and piece_moved_upon.side != self.side
            moves << move_vector 
          end
          return moves
        end

        #otherwise there was no collision, append the move and move down the line        
        moves << move_vector if vector_allowed_from(from_position, move_vector, board) 
      end
      moves    
  end
  
  # Creates a piece knowing at least its role and side
  def initialize(role, side, which=nil)
    @role = role 
    @side = side
    @which = which 
    
    #TODO - this is moving out of instance data
    @lines_of_attack = []
    @direct_moves = []
  end

  
  #define static methods of piece class here
  class << self
    def role_to_abbrev(role)
      return 'N' if role == :knight 
      return role.to_s[0,1].upcase unless role == :pawn
    end
    
    def abbrev_to_role(char)
      return :knight  if char=='N'
      return :king    if char=='K'
      return :queen   if char=='Q'
      return :bishop  if char=='B'
      return :rook    if char=='R'
      return :pawn    if ('a'..'h').to_a.include?(char)
    end
  end

end

