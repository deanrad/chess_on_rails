# A Board is a snapshot of a match at a moment in time, implemented as a hash
# whose keys are positions and whose values are the pieces at those positions
class Board < Hash

  # the to, from, and enpassant ranks for each side
  EN_PASSANT_CONFIG = {:white => [2, 4, 3], :black => [7, 5, 6] }

  include Fen

  attr_accessor :match	
  attr_accessor :en_passant_square
  
  alias :pieces	            :values
  alias :occupied_positions :keys

  # Creates a board initialized at the default starting position, or from FEN if given
  def initialize( start_pos = nil )
    return _initialize_fen( start_pos ) if start_pos && Fen::is_fen?(start_pos) && !Pgn::is_pgn?(start_pos)
    Chess.setup_board(self)
  end

  def [] x
    x = x.to_sym
    super
  end

  # updates internals with a given move played
  # Dereferences any existing piece we're moving onto or capturing enpassant
  # Updates our EP square or nils it out
  def play_move!( m )
    self.delete_if { |pos, piece| pos == m.to_coord || pos == m.captured_piece_coord }

    piece_moved = self.delete(m.from_coord)
    self[m.to_coord] = piece_moved

    if m.castled==1
      castling_rank = m.to_coord.rank.to_s
      [['g', 'f', 'h'], ['c', 'd', 'a']].each do |king_file, new_rook_file, orig_rook_file|
        #update the position of the rook corresponding to the square the king landed on
	if m.to_coord.file == king_file 
	   rook = self.delete("#{orig_rook_file}#{castling_rank}")
	   self["#{new_rook_file}#{castling_rank}"] = rook
	end
      end
    end
    
    #TODO investigate why this method is getting called multiply per moves << Move.new
    return unless piece_moved
    ep_from_rank, ep_to_rank, ep_rank = EN_PASSANT_CONFIG[ piece_moved.side ]
    @en_passant_square = ( piece_moved.function == :pawn &&
                           m.from_coord.rank == ep_from_rank && 
                           m.to_coord.rank == ep_to_rank ) ? m.from_coord.file + ep_rank.to_s : nil

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
    considered.play_move!(m)
    return considered unless block_given?
    yield  considered
  end

  def previous_board
    return nil if match.nil?
    
    return self if (idx = match.boards.index(self))==0
    match.boards[ idx - 1 ]
  end

  def side_occupying(pos)
    p = self[pos]
    return nil if !p 
    return p.side
  end

  def sister_piece_of( a_piece, sitting_here )
    pos, piece = select do |pos, piece| 
      piece.side == a_piece.side && 
      piece.function == a_piece.function && 
      pos != sitting_here
    end
    piece
  end
  
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

  #simplest logic here - if theres a move you're allowed which gets you out of check, you're not in checkmate
  #contrast with more intelligent Capture/Block/Evade strategy
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

  #provides a format for tracing
  def to_s( for_black = false )
    output = '' # ' ' * (8 * 8 * 2) #spaces or newlines after each 
    ranks  = %w{ 8 7 6 5 4 3 2 1 }
    files  = %w{ a b c d e f g h } 
    (ranks.reverse! and files.reverse!) if for_black
    last_file = files.last
    ranks.each do |rank|
      files.each do |file|
        piece = self[ file + rank ]
        #output << file+rank
        output << (piece ? piece.abbrev : ' ')
        output << (file != last_file ? ' ' : "\n")
      end
    end  
    output + "\n"
  end
  
  def inspect; "\n" + to_s; end

end
