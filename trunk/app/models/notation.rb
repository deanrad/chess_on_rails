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

  #                  1=piece moving   2=disambig  3=capture 4=coord 5/6=promo
  NOTATION_REGEX = /([KQBNRabcdefgh])?([a-h1-8]?)(x)?([a-h][1-8])(=([QBNR]))?[+!?#]*/
  
  attr_accessor :role, :disambiguator, :capture, :to_coord, :from_coord, :promotion_choice, :check, :checkmate, :board, :next_to_move
  
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
    @notation || castling_notation_from_fields || create_notation_from_fields
  end

  # Allows a caller to get the coordinates represented by a move, or an error
  def to_coords
    return [@from_coord, @to_coord] if @from_coord && @to_coord
    @from_coord, @to_coord = parse_notation
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
  
  def castling_notation_from_fields
    k = @board[@from_coord]
    return nil unless k && k.role == :king
    vector = Position.new(@to_coord) - Position.new(@from_coord)
    return nil unless k.is_castling_move?( @from_coord, vector, @board)
    vector[1] > 0 ? "O-O" : "O-O-O" #kingside is in increasing direction of files a-h
  end
  
  #unless you are using this class to interpret a notation, serializes fields into notation conforming
  # to the chess notion of algebraic notation
  def create_notation_from_fields
    @notation = ''
    
    #first letter is the role of the piece moving (for non-pawns)
    @role = role_at_coord(@from_coord) 
    @notation += Notation.abbrev(@role)
    @notation += disambiguator_notation || ''
    @notation += 'x' if capture_occurred
    @notation += @to_coord.to_s
    @notation += promotion_notation || ''
    @notation += check_notation || ''
    @notation
  end
  
  def parse_notation
    parse_castle || parse_regular
  end
  
  def parse_castle
    return unless @notation =~ /O-O(-O)?/
    from_file = "e"                           #castling always from e
    rank = @next_to_move == :black ? "8" : "1"
    to_file = $1 ? "c" : "g"
    [ Position.new( from_file, rank ).to_sym , Position.new( to_file, rank ).to_sym ] 
  end
  
  def parse_regular
    raise Exception, "Unrecognized notation #{@notation}" unless @notation =~ NOTATION_REGEX
    # 1=piece moving   2=disambig  3=capture 4=coord 5/6=promo
    # puts [$1, $2, $3, $4, $5, $6].inspect
    @role = Notation.role_of($1)
    @disambiguator = $2
    @capture = !$3.blank?
    @to_coord = Position.new($4).to_sym
    @promotion_choice = $6    

    possible_froms = @board.keys.select do |k| 
      @board[k] && @board[k].role==@role && @board.allowed_moves(k).include?(@to_coord)
    end
    
    @from_coord = (possible_froms.length==1 && possible_froms[0]) || disambiguate( possible_froms )
        
    from, to = Position.new(@from_coord), Position.new(@to_coord)
    raise Exception, "Unable to determine move from notation #{@notation}" unless from.valid? and to.valid?
    [@from_coord, @to_coord]
  end

  def disambiguate( possible_froms )
    raise Exception, "More than one #{@role} can move to #{@to_coord}. Please include a file or rank - Nbc3 or N5f7 for example." if @disambiguator.blank?
    
    match1, match2 = possible_froms.select{|f| f.to_s.include?(@disambiguator) }
    return match1 unless match2
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
  
  def disambiguator_notation
    piece = @board[@from_coord]
    
    #return if not a piece that can be ambiguous
    return unless piece and [:knight, :rook, :pawn].include?(piece.role)
    
    sister_pieces = @board.values.select do |p|
      p.side==piece.side and p.role==piece.role and p.side_id != piece.side_id 
    end
    
    return unless sister_pieces and sister_pieces.length > 0
    
    #for now only support first piece
    sister_piece_square = @board.invert[ sister_pieces[0] ]
    
    return unless @board.allowed_moves( sister_piece_square ).include?( @to_coord )
    
    #now determine whether to disabmiguate with rank or file
    real, imposter = [Position.new(@from_coord), Position.new(sister_piece_square)]
    return real.file_char unless real.file == imposter.file
    return real.rank.to_s
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
    return '#' if @checkmate
    return '+' if @check
    side_moved_on = Sides.opposite_of(@board[@from_coord].side)
    @board.consider_move( Move.new(:from_coord => @from_coord, :to_coord => @to_coord) ) do
      @check = @board.in_check?(side_moved_on) 
    end
    return '+' if @check
  end
end
