# Allows boards to be created without move history
# Per Forsyth-Edwards Notation
class Fen < String
  class Error < ArgumentError; end

  attr_accessor :board, :side_to_move, :castlings, :en_passant_square
  
  def parse
    board, side_to_move, castlings, en_passant_square = self.split(/\s+/)
    ranks = board.split('/')
    raise Error, "Invalid Fen, all 8 ranks must be specified" unless ranks.length == 8
    pieces = []
    
    #board
    ranks.each_with_index do | rank_fen, rank_idx |
      to_pieces(rank_fen, rank_idx+1) do | pos_and_piece |
        pieces << pos_and_piece
      end
    end
    self.board = Board[ *(pieces.flatten) ]
    
    #side_to_move
    if side_to_move.nil? || !%{w b}.include?(side_to_move)
      self.side_to_move = :white
    else
      self.side_to_move = side_to_move == 'w' ? :white : :black
    end
    self.board.side_to_move = self.side_to_move
    
    #en_passant
    if en_passant_square
      if  !Chess.valid_position?(en_passant_square)
        raise Error, "Invalid en_passant_square #{en_passant_square}" 
      else
        self.en_passant_square = en_passant_square.to_sym
      end
    end
    self.board.en_passant_square = self.en_passant_square
    
    #castlings
    if castlings && castlings =~ /[kqKQ]{0,4}/
      self.castlings = castlings
      [[:white, :kings], [:white, :queens], [:black, :kings], [:black, :queens]].each do |side, flank|
        self.board.send( "#{side}_can_castle_#{flank}ide=", can_castle?(side, flank) )
      end
    end
    self.board
  end
    
private 
  # Given a rank, and when self is a string like "R3K2R", to_pieces yields
  # arrays of positions and pieces, eg [:b2, Pawn.new(:white)]
	def to_pieces( rank_fen, rank )
		file = nil
		rank_fen.split('').each_with_index do |char, i|
			file ||= i+97-1
			if char.to_i == 0
				file = file + 1 
				pos = :"#{file.chr}#{rank}"
				yield [ pos, Piece.new_from_fen(char, pos) ]
			else
				file += char.to_i 
			end
			
			if i == rank_fen.split('').length - 1
			  unless file == 104
			    raise Error, "Invalid fen substring #{self}. A fen rank must specify exactly 8 positions" 
			  end
			end
		end
	end
	
	def can_castle? side, flank
    return nil unless [:white,:black].include?(side) && [:queens,:kings].include?(flank)
    ltr = flank==:queens ? 'Q' : 'K'
    ltr.downcase! if side == :black
    self.castlings.include?(ltr)
  end
end

