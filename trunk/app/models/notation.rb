#A class which serializes deserializes and interprets algebraic chess notations
# according to the pieces they move, their destination squares, and the actions (promotions, captures, checks)
# they produce along the way

class Notation
  def initialize(*args)  
    if args.length == 3
      init_from_coords_and_board(args[0], args[1], args[2])
    elsif args.length == 2
      init_from_notation_and_board(args[0], args[1])
    end
  end

  attr_accessor :role, :capture, :to_coord, :from_coord, :promotion_choice, :check, :checkmate, :board
  
  #we may be setting notation in the event of interpreting it, or getting it in the case of creating it
  attr_accessor :notation
  
  def self.abbrev(role)
    Piece.role_to_abbrev(role) || ''
  end
  def self.role_of(abbrev)
    Piece.abbrev_to_role(abbrev)
  end
  
  #does the work of serializing an instance of this class for display or db storage
  def to_s
    @notation || create_notation_from_fields
  end
  
  private
  
  def init_from_coords_and_board(from_coord, to_coord, board)
    @from_coord = from_coord
    @to_coord = to_coord
    @board = board
  end
  
  def init_from_notation_and_board(note, board)
    @notation = note
    @board = board
  end
  
  def from_notation?
    @from_coord == nil
  end
  
  #unless you are using this class to interpret a notation, serializes fields into notation conforming
  # to the chess notion of algebraic notation
  def create_notation_from_fields
    @notation = ''
    
    #first letter is the role of the piece moving (for non-pawns)
    @role = role_at_coord(@from_coord) 
    @capture = capture_occurred
    @notation += Notation.abbrev(@role)
    @notation += 'x' if capture
    @notation += @to_coord.to_s
    @notation += promotion_notation || ''
    @notation += check_notation || ''
    @notation
  end
  
  def role_at_coord(coord)
    piece = @board[coord]
        raise ArgumentError, coord unless piece
    piece.role
  end
  
  def capture_occurred
    from, to = [ @board[@from_coord], @board[@to_coord] ]
    return from && to && (from.side != to.side)
  end
  
  def promotion_notation
    return unless role_at_coord(@from_coord)==:pawn

    #TODO will need access to the whole move - anyway should pass in move rather than coords since its
    # a good little object with many helpful properties
    pawn = @board[@from_coord]
    other_side = Sides.opposite_of(pawn.side)
    return unless Position.new(@to_coord).rank == Sides[other_side].back_rank
    "=Q"
  end
  
  def check_notation
    side_moved_on = Sides.opposite_of(@board[@from_coord].side)
    @board.consider_move( Move.new(:from_coord => @from_coord, :to_coord => @to_coord) ) do
      @check = @board.in_check?(side_moved_on) 
    end
    return '+' if @check
  end
end