# A Board is a snapshot of a match at a moment in time, implemented as a hash
# whose keys are positions and whose values are the pieces at those positions
class Board < Hash

  include Fen

  attr_accessor :match	
  
  alias :pieces	   :values
  alias :positions :keys

  #todo remove need for pieces
  def initialize( *args )
    if args.length == 2
      _initialize args[0], args[1]
    elsif args.length == 1
      _initialize_fen( args[0] )
    end
  end

  # TODO eliminate the string underpinnings of this class once callers use symbols / vectors
  def [] x
    super(x.to_s)
  end

  def _initialize(match, pieces_with_positions)
    #puts "initializing board"
    
    #initialize from the game's initial board, but replay moves...
    pieces_with_positions.each do | piece, pos |
      self[pos] = piece
    end

    @match = match
    
    #replay the board to that position
    @match.moves.each{ |m| play_move!(m) }
    
  end
  
  def each_square &block
    "12345678".each_char do |rank|
      "abcdefgh".each_char do |file|
        yield "#{file}#{rank}"
      end
    end
  end

  # updates internals with a given move played
  def play_move!( m )
    #kill any existing piece we're moving onto or capturing enpassant
    self.delete_if { |pos, piece| pos == m.to_coord || pos == m.captured_piece_coord }
    #@pieces.reject!{ |p| (p.position == m.to_coord) || (p.position == m.captured_piece_coord) }	

    #move to that square
    piece_moved = self.delete(m.from_coord)
    self[m.to_coord] = piece_moved

    #@pieces.each{ |p| p.position = m.to_coord and piece_moved = p if p.position==m.from_coord }

    #reflect castling
    if m.castled==1
      castling_rank = m.to_coord[1].chr
      [['g', 'f', 'h'], ['c', 'd', 'a']].each do |king_file, new_rook_file, orig_rook_file|
        #update the position of the rook corresponding to the square the king landed on
	if m.to_coord[0].chr==king_file 
	   rook = self.delete("#{orig_rook_file}#{castling_rank}")
	   self["#{new_rook_file}#{castling_rank}"] = rook
	end
        #@pieces.each { |p| p.position = "#{rook_file}#{castling_rank}" if m.to_coord[0].chr==king_file && p.position=="#{orig_rook_file}#{castling_rank}"}
      end
    end

    #reflect promotion
    if piece_moved.function == :pawn and m.to_coord.rank == piece_moved.promotion_rank
      piece_moved.function = Move::NOTATION_TO_ROLE_MAP[ m.promotion_choice ].to_sym 
      piece_moved.disambiguator = :promoted
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
    considered_board = Marshal::load(Marshal.dump(self)) #deep copy to decouple pieces array
    considered_board.play_move!(m)

    return considered_board unless block
    yield(considered_board)
  end

  def side_occupying(pos)
    p = self[pos]
    return nil if !p 
    return p.side
  end

  def sister_piece_of( a_piece, sitting_here )
    pos, piece = select do |pos, piece| 
      piece.side == a_piece.side && 
      piece.role == a_piece.role && 
      pos != sitting_here
    end
    piece
  end
  
  def in_check?( side )

    king_pos, king  = detect do |pos, piece| 
      piece.role=='king' && piece.side == side 
    end

    assassin = self.detect do |position, attacker|
      (attacker.side != side) &&
      attacker.allowed_moves(self).include?(king_pos.to_s)
    end

    !! assassin
  end

  def is_en_passant_capture?( from_coord, to_coord ) 

    to_rank, to_file = to_coord[1].chr, to_coord[0].chr
    return false unless p = self[ from_coord ]

    capture_rank, advanced_pawn_rank, original_pawn_rank = (p.side==:white) ? %w{ 6 5 7 } : %w{ 3 4 2 }
    possible_advanced_pawn = self[ to_file + advanced_pawn_rank ]

    #if behind a pawn
    if (to_rank == capture_rank) && possible_advanced_pawn && (possible_advanced_pawn.role=='pawn') 
      #and that pawn was doubly (not singly) advanced
      @match.moves.find_by_from_coord_and_to_coord( ( to_file + original_pawn_rank ) , to_file + advanced_pawn_rank ) != nil
    else
      return false
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
    last_file = files[7]
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
