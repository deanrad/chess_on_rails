require 'piece'
# A Board is a snapshot of a match at a moment in time, implemented as a hash
# whose keys are positions and whose values are the pieces at those positions
class Board < Hash

  include KnowledgeOfBoard

  # bring in the ability to notate boards as Forsyth-Edwards notation
  include Fen

  # if true, this board instance is used for computation only, otherwise it is
  # or was an actual state of the game - defaults to nil
  attr_accessor :hypothetical

  # the match of which this board takes part
  attr_accessor :match	

  # flags whether an en_passant move is available (inferred from match)
  attr_accessor :en_passant_square

  # flags true initially, and becomes false for this and future boards in the match
  # if king or kings rook is moved. Other castling rules still apply
  attr_accessor :white_kingside_castle_available, :white_queenside_castle_available
  attr_accessor :black_kingside_castle_available, :black_queenside_castle_available

  # flags true initially, and becomes false for this and future boards in the match
  # if king or queens rook is moved. Other castling rules still apply
  
  alias :pieces	   :values
  alias :positions :keys

  # Creates a board initialized at the default starting position, or from FEN if given
  def initialize( start_pos = nil )
    return _initialize_fen( start_pos ) if start_pos
    reset!
    self.white_kingside_castle_available  = true
    self.white_queenside_castle_available = true
    self.black_kingside_castle_available  = true
    self.black_queenside_castle_available = true
  end

  # TODO eliminate the string underpinnings of this class once callers use symbols / vectors
  def [] pos
    pos = pos.to_sym unless Symbol===pos
    super(pos)
  end
  def []= pos, val
    pos = pos.to_sym unless Symbol===pos
    super(pos, val)
  end

  # Resets the board to initial position
  def reset!
    PAWN_RANKS.each do |rank, side|
      POSITIONS[8 - rank].each do |pos|
        self[pos] = Pawn.new(side, pos.to_s[0..1])
      end
    end

    HOME_RANKS.each do |rank, side|
      POSITIONS[8 - rank].each_with_index do |pos, file_idx|
        disc, func = HOME_LINEUP[file_idx]
        self[pos] = ::Piece.class_for(func).new(side, disc)
      end
    end
  end

  
  # updates internals with a given move played
  # Dereferences any existing piece we're moving onto or capturing enpassant
  # Updates our EP square or nils it out
  def play_move!( m )
    #$stderr.puts "Recording move #{m.from_coord}->#{m.to_coord} on board instance #{self.object_id}" unless self.hypothetical
    from_coord, to_coord, captured_piece_coord = [m.from_coord.to_sym, m.to_coord.to_sym, m.captured_piece_coord && m.captured_piece_coord.to_sym]
    self.delete_if { |pos, piece| pos == to_coord || pos == captured_piece_coord }

    piece_moved = self.delete(from_coord)
    self[to_coord] = piece_moved

    if m.castled==1
      castling_rank = to_coord.rank.to_s
      [['g', 'f', 'h'], ['c', 'd', 'a']].each do |king_file, new_rook_file, orig_rook_file|
        #update the position of the rook corresponding to the square the king landed on
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
    
    #TODO investigate why this method is getting called multiply per moves << Move.new
    return unless piece_moved
    ep_from_rank, ep_to_rank, ep_rank = EN_PASSANT_CONFIG[ piece_moved.side ]
    self.en_passant_square = ( piece_moved.function == :pawn &&
                           m.from_coord.rank == ep_from_rank && 
                           m.to_coord.rank == ep_to_rank ) ? (m.from_coord.file + ep_rank.to_s).to_sym : nil

    #reflect promotion
    if piece_moved && piece_moved.function == :pawn && m.to_coord.to_s.rank == piece_moved.promotion_rank
      self.delete(m.to_coord)
      self[m.to_coord] = Queen.new(piece_moved.side, :promoted)
    end
    
    self
  end
 
  # returns a copy of self with move played
  # examples: 
  # # block style for instant answer
  # woot = board.consider_move( Move.new(...) ){ in_check?( :black ) } 
  # # get the board for future consideration
  # new = board.consider_move( Move.new(...) )
  def consider_move(m, &block)
    considered = self.dup

    considered.hypothetical = true
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

    assassin = self.detect do |position, attacker|
      attacker && (attacker.side != side) &&
      attacker.allowed_moves(self).include?(king_pos.to_sym)
    end

    !! assassin
  end

  # Says whether you are a pawn moving sideways onto an empty square
  #  when an enpassant capture is available
  def en_passant_capture?( from_coord, to_coord ) 
    with ( self[from_coord] ) do |pawn|
      return false unless pawn.function == :pawn
      return false unless self.en_passant_square
      return (from_coord.file != to_coord.file) && (self[to_coord]==nil)
    end
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
    output = '' # ' ' * (8 * 8 * 2) #spaces or newlines after each 
    ranks  = %w{ 8 7 6 5 4 3 2 1 }
    files  = %w{ a b c d e f g h } 
    (ranks.reverse! and files.reverse!) if for_black
    last_file = files[7]
    ranks.each do |rank|
      files.each do |file|
        piece = self[ file + rank ]
        output << (piece ? piece.abbrev : ' ')
        output << (file != last_file ? ' ' : "\n")
      end
    end  
    output + "\n"
  end

  # Two boards hash to the same value if their fen strings are identical.
  def hash
    self.to_fen.hash
  end

  def inspect; "\n" + to_s; end

end
