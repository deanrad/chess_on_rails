# Extends a board to allow round-tripping from Forsyth-Edwards (FEN) notation
module Fen

  # Called by Board.initialize to populate itself.
  def _initialize_fen str
    @pieces = []  

    validate! str

    @fenstr = FenString.new(str)
    @fenstr.ranks.each_with_index do |rank, rank_num|
      current_file = 1   
      rank.each_char do |instr|
        if instr.match FenString::PIECE_REGEX
          place_piece( current_file, rank_num, instr )
          current_file += 1
        else
          current_file += instr.to_i 
        end
        next if current_file >= 8
      end
    end
  end

  # Returns the current state of the board as a string of FEN.
  def to_fen
    fen = ''
    consec_space = 0; this_file = 1

    # from whites lower left, across each file in ascending order, then in ascending rank
    Board::POSITIONS.reverse.flatten.each do |pos|
      piece = self[pos]
      if piece
        fen << (consec_space > 0 ? consec_space.to_s : '') << piece.abbrev and consec_space=0 
      else
        consec_space += 1
      end
      this_file += 1
      if this_file > 8
        #fen << (consec_space == 8 ? consec_space.to_s : '') << '/'
        fen << (consec_space > 1 ? consec_space.to_s : '') << '/'
        this_file = 1 ; consec_space = 0
      end
    end

    fen.chop

    # field 2 - the next to move 
    if match
      fen << " %s" % match.next_to_move.to_s[0..0]
    end

    # field 3 - castlings available
    castle_codes = [[:white_kingside, 'K'], [:white_queenside, 'Q'], [:black_kingside, 'k'], [:black_queenside, 'q']]
    open_castles = castle_codes.inject("") do |c, (sym, cd) |
      c << cd if self.send("#{sym}_castle_available")
      c
    end
    fen << " %s" % (open_castles.blank? ? "-" : open_castles)

    # field 4 - en passant square
    fen << " %s" % (self.en_passant_square || "-")

    fen
  end

  # verifies validity or throws error
  def validate! str

  end 

  # Primitive implementation of FEN detection
  def self.is_fen?( str )
    str.split('/').length > 5
  end

  # creates and places a piece based on 1-based indices of rank and file
  def place_piece( current_file, rank, instr )
    piece = Fen::Piece.new

    piece.side = instr.upcase == instr ? :white : :black
    piece.role = case instr.upcase
      when 'K' then :king
      when 'Q' then :queen
      when 'B' then :bishop
      when 'N' then :knight
      when 'R' then :rook
      when 'P' then :pawn
    end
    @pieces << piece.to_piece
    # piece.position = "#{(current_file+96).chr}#{rank+1}"
    self["#{(current_file+96).chr}#{rank+1}".to_sym] = piece.to_piece
  end
  
  # if we have a fen string, whatever that fen string says
  def next_to_move
    return nil unless @fenstr
    @fenstr.next_to_move == 'b' ? :black : :white
  end

  private

  # the fields of a fen string
  class FenString
    PIECE_REGEX = /[rnbkqp]/i

    # the original text
    attr_accessor :text 

    # the fields comprising the full text 
    attr_accessor :pieces, :next_to_move, :allowed_castles

    def initialize str
      self.text = str
      @pieces, @next_to_move, @allowed_castles = text.split /\s+/
    end

    # the array of rank sections
    def ranks
      pieces.split '/'
    end

    def to_s; self.text; end
  end


  # a piece, as Fen sees it
  class Piece
    attr_accessor :role
    attr_accessor :side 

    # Converts to the Fen::Piece object to a descendant of ::Piece
    def to_piece
      Kernel.const_get(@role.to_s.classify).new( @side )
    end
  end
end
