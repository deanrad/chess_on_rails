require 'piece'
# A Board is a snapshot of a match at a moment in time, implemented as a hash
# whose keys are positions and whose values are the pieces at those positions
# TODO It's very important to determine if a board instance is supposed to get
# all the moves played back on it, or if a separate instance is created afresh
class Board < Hash

  class MoveInvalid     < ::Exception; end
  class MissingCoord    < ::Exception; end
  class PieceNotFound   < ::Exception; end

  include KnowledgeOfBoard

  class << self
    attr_accessor_with_default :memoize_moves, true
  end

  # The match to which this board belongs.
  attr_accessor :match	

  # A flag for whether an en_passant move is available for the next move only.
  attr_accessor :en_passant_square

  # The piece most recently moved.
  attr_accessor :piece_moved; alias :piece_last_moved :piece_moved

  # The piece just promoted.
  attr_accessor :promoted_piece

  # Flags that are true initially, and become false for this and future boards in the match
  # if king or kings rook is moved. Major contributors to whether castling is allowed.
  attr_accessor :white_kingside_castle_available, :white_queenside_castle_available
  attr_accessor :black_kingside_castle_available, :black_queenside_castle_available

  # An array of pieces which have bitten the dust during this match.
  attr_accessor :graveyard

  # The rules (implemented as lambda methods) against which moves must abide.
  attr_accessor :move_validations

  alias :pieces	   :values
  alias :positions :keys

  # Creates a board initialized at the default starting position, or from FEN if given
  def initialize( start_pos = nil )
    # allow initialization from a hash of position => piece
    case start_pos
      when Hash; start_pos.each{ |k,v| self[k] =v }
      #since loading of the plugin that gives us the _initialize_fen method is
      #screwy, leave it commented out for now
      #when String; return _initialize_fen( start_pos )
      when nil; reset! 
    end
    self.white_kingside_castle_available  = true
    self.white_queenside_castle_available = true
    self.black_kingside_castle_available  = true
    self.black_queenside_castle_available = true
    self.graveyard = Graveyard.new
  end

  # Allow for indifferent string/sym access, though using symbols internally
  def [] pos;        super(pos.to_sym);       end
  def []= pos, val;  super(pos.to_sym, val);  end

  # Resets the board to initial position
  def reset!
    PAWN_RANKS.each do |rank, side|
      POSITIONS[8 - rank].each do |pos|
        self[pos] = Pawn.new(side, pos.file)
      end
    end

    HOME_RANKS.each do |rank, side|
      POSITIONS[8 - rank].each_with_index do |pos, file_idx|
        disc, func = HOME_LINEUP[file_idx]
        self[pos] = ::Piece.class_for(func).new(side, disc)
      end
    end
  end

  
  # Implements the rules of play on this Board instance, for the (presumably
  # allowed) move given.
  def play_move!( m )
    raise MoveInvalid, m.errors.full_messages unless m.errors.empty?

    unless m.notation_inferred
      m.infer_coordinates_from_notation(self) rescue nil
    end

    raise MissingCoord, m.inspect unless begin
      m && m.respond_to?(:from_coord) && !m.from_coord.blank? &&
           m.respond_to?(:to_coord)   && !m.to_coord.blank?
    end
    raise PieceNotFound, [m.inspect,self.inspect].join("\n") if self[m.from_coord.to_sym].nil?

    # locally cache this information
    from_coord = m.from_coord.to_sym
    to_coord = m.to_coord.to_sym
    captured_piece_coord = captured_piece_coord && m.captured_piece_coord.to_sym

    # If the move is already populated with a captured piece coordinate, use that to delete and be done
    # Otherwise, delete whats at the to_coord and populate the moves captured piece coordinate.
    if captured_piece_coord
      graveyard << self.delete(captured_piece_coord)
    else
      if deceased = self.delete(to_coord)
        graveyard << deceased
      end
    end

    # Place the piece in its new spot (the board itself does not restrict where)
    self.piece_moved = self.delete(from_coord)
    self[to_coord] = piece_moved

    # TODO move the 'magic' of castling (as two moves) outside of Board, and feed
    # these two moves into the board for playback. (Also you could make the rook's
    # castling square an 'allowed move' for that rook, to allow castling by dragging
    # the rook, and more consistent behavior. Then castling would be the sum of two
    # legal, allowed moves, performed successively by the same player. Piece_moved
    # would remain the king.
    # implement the switching of the king and rook if told to do so
    if m.castled==1
      castling_rank = to_coord.rank.to_s
      [['g', 'f', 'h'], ['c', 'd', 'a']].each do |king_file, new_rook_file, orig_rook_file|
	if to_coord.file == king_file 
	   rook = self.delete(:"#{orig_rook_file}#{castling_rank}")
	   self[:"#{new_rook_file}#{castling_rank}"] = rook
	end
      end
    end

    # prevent future castling once kings moved
    case piece_moved.function 
    when :king
      self.send("#{piece_moved.side}_kingside_castle_available=", false)
      self.send("#{piece_moved.side}_queenside_castle_available=", false)
    when :rook
      flank = piece_moved.discriminator.to_s.singularize
      self.send("#{piece_moved.side}_#{flank}side_castle_available=", false)
    end

    # publish whether this move created an en passant option for the opponent
    ep_from_rank, ep_to_rank, ep_rank = EN_PASSANT_CONFIG[ piece_moved.side ]

    @is_ep = piece_moved.function == :pawn && 
             ep_from_rank == m.from_coord.rank &&
             ep_to_rank  == m.to_coord.rank

    self.en_passant_square = @is_ep ? (m.from_coord.file + ep_rank.to_s).to_sym : nil
      
    #reflect promotion
    if piece_moved && piece_moved.function == :pawn && m.to_coord.to_s.rank == piece_moved.promotion_rank
      self.promoted_piece = Queen.new(piece_moved.side, :promoted) # TODO switch
      m.promotion_choice = "Q"
      self.delete(m.to_coord)
      self[m.to_coord] = promoted_piece
    end

    m.board_after = self
  end
 
  # returns a copy of self with move played
  # examples: 
  # # block style for instant answer
  # woot = board.consider_move( Move.new(...) ){ in_check?( :black ) } 
  # # get the board for future consideration
  # new = board.consider_move( Move.new(...) )
  def consider_move(m, &block)
    # shallow-copy - we dont want (and don't get) copies of the pieces
    considered = self.dup 

    considered.play_move!(m)
    return considered unless block_given?
    yield  considered
  end

  # The board prior to this move being played
  def previous_board
    return nil if match.nil?
    return self if (idx = match.boards.index(self))==0
    match.boards[ idx - 1 ]
  end

  # The side of a piece on this position, or nil if the position is empty
  def side_occupying(pos)
    self[pos] && self[pos].side
  end

  # flags whether the :white, :queens castling squares are empty, for example
  def castling_squares_empty?(side, flank)
    files = case flank when :queens then %w{b c d} else %w{f g} end
    occupied = files.inject(false) do |res, file| 
      res ||= self.has_key?(:"#{file}#{side.back_rank}")
    end
    !occupied
  end

  # Looks for a piece of the same function (rook, etc..) as the piece given, returning
  # either [position, piece] or [nil, nil]
  def sister_piece_of( a_piece )
    sitting_at = index(a_piece)
    pos, piece = select do |pos, piece| 
      piece.side == a_piece.side && 
      piece.function == a_piece.function && 
      pos != sitting_at
    end.flatten 
    [pos, piece]
  end
  
  # Answers whether the side argument passed (:white or :black) is in check.
  def in_check?( side )
    king_pos, king  = detect do |pos, piece| 
      piece && piece.function==:king && piece.side == side 
    end
    return nil unless king_pos

    assassin_pos, assassin = self.detect do |position, attacker|
      attacker && (attacker.side != side) &&
      attacker.allowed_moves(self).include?(king_pos.to_sym)
    end

    !! assassin
  end

  # Employs the logic that if theres a move you're allowed which gets you out of check, you're not in checkmate,
  # otherwise you are. Contrast with more intelligent Capture/Block/Evade strategy
  def in_checkmate?( side )

    return false unless in_check?( side )
    
    way_out = false
    each_pair do |pos, piece|
      next if piece.side != side
      return false if way_out

      piece.allowed_moves(self).each do |mv|
        consider_move( Move.new( :from_coord => pos, :to_coord => mv ) ) do |b|
	  way_out = ! b.in_check?( side )
	end
      end

    end
    return !way_out
  end

  # Provides a format for tracing.
  def to_s( for_black = false )
    returning("") do |output|
      Board.all_positions( for_black ? :black : :white ).each_slice(8) do |row|
        output << row.map do |sq| 
          (p=self[sq]) && p.abbrev || ' '
        end.join(' ') + "\n"
      end
    end + "\n"
  end

  def inspect; "\n" + to_s; end

  # Emits a client-side representations of self starting at a1
  def to_json
    @json ||= returning("{") do |json|
      POSITIONS.reverse.flatten.each do |pos|
        json << %Q|"#{pos}":#{self[pos].to_json},\n| if self[pos]
      end
      json.chop!.chop! << "}"
    end
  end

  # Allows for caching and emitting of allowed moves for this board
  def allowed_moves
    @allowed_moves_per_position ||= {}
  end

end
