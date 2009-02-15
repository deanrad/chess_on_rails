# Extends a board to allow round-tripping from Forsyth-Edwards (FEN) notation
module Fen

  # called by Board.initialize to populate the pieces array
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

  # spits out the current state of the board
  def to_fen
    fen = ''
    consec_space = 0; this_file = 1

    self.each_piece_in_fen_order do |piece| 
      if piece
        fen << (consec_space > 0 ? consec_space.to_s : '') << piece.abbrev(:fen) and consec_space=0 
      else
        consec_space += 1
      end
      this_file += 1
      if this_file > 8
        fen << (consec_space == 8 ? consec_space.to_s : '') << '/'
        this_file = 1 ; consec_space = 0
      end
    end

     fen.chomp
  end

  # verifies validity or throws error
  def validate! str

  end 

  # creates and places a piece based on 1-based indices of rank and file
  def place_piece( current_file, rank, instr )
    piece = Fen::Piece.new
    piece.position = "#{(current_file+96).chr}#{rank+1}"
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
  end
  
  # defines the order in which we iterate over the board while 
  # generating Fen
  # (only for implementations of board lacking each)
  def each_piece_in_fen_order
    "12345678".each_char do |rank|
      "abcdefgh".each_char do |file|
        yield self[ "#{file}#{rank}" ]
      end
    end
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

    # yes, i know this is less a property of the piece than the board. It's
    # handy to tote the position around with the piece for now.
    attr_accessor :position 

    # converts to the Piece object of our app with its crazy 'type' field
    def to_piece
      type = case role
        when :pawn then :a_pawn
        when :queen then :queen
        when :king  then :king
        else :"kings_#{role}"
      end
      ::Piece.new( side, type, position )
    end
  end
end

#for ruby < 1.9 to use ruby 1.9 each_char unicode safe syntax
class String
  def each_char
    (0..self.length-1).each { |place| yield self[place..place] }
  end
end
