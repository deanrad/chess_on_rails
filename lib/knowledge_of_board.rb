# Confers upon the includer knowledge of the chess board - its positions, sides, etc..
# As a side effect and performance boost, adds memoization support for class methods,
# and memoizes them.
# TODO eliminate duplicately stored information in this file
module KnowledgeOfBoard
  # Array of arrays of symbols representing white's view of the board
  POSITIONS = [ [:a8, :b8, :c8, :d8, :e8, :f8, :g8, :h8],
                [:a7, :b7, :c7, :d7, :e7, :f7, :g7, :h7],
                [:a6, :b6, :c6, :d6, :e6, :f6, :g6, :h6],
                [:a5, :b5, :c5, :d5, :e5, :f5, :g5, :h5],
                [:a4, :b4, :c4, :d4, :e4, :f4, :g4, :h4],
                [:a3, :b3, :c3, :d3, :e3, :f3, :g3, :h3],
                [:a2, :b2, :c2, :d2, :e2, :f2, :g2, :h2] ,
                [:a1, :b1, :c1, :d1, :e1, :f1, :g1, :h1] ]

  PAWN_RANKS   = [ [2, :white], [7, :black] ]
  HOME_RANKS   = [ [1, :white], [8, :black] ]
  HOME_LINEUP  = [ [:queens, :rook], [:queens, :knight], [:queens, :bishop],
                   [nil, :queen], [nil, :king],
                   [:kings, :bishop], [:kings, :knight], [:kings, :rook] ]

  # the to, from, and enpassant ranks for each side
  EN_PASSANT_CONFIG = {:white => [2, 4, 3], :black => [7, 5, 6] }

  # Endows the includer (Board) with methods defined in our ClassMethods module
  def self.included base
    super
    base.extend(ClassMethods)
  end

  module ClassMethods
    extend ActiveSupport::Memoizable
    
    #Gets all_positions, optionally seen from black's side, passing :black or true (memoized)
    def all_positions side=:white
      side==:white ? POSITIONS.flatten : POSITIONS.dup.reverse.map(&:reverse!)
    end
    memoize :all_positions
    
    def ranks side=:white
      white_ranks = POSITIONS.reverse.map{ |rank| rank[0].to_s[1..1] }
      side==:white ? white_ranks : white_ranks.reverse
    end
    memoize :ranks

    def files side=:white
      white_files = POSITIONS[0].map{ |pos| pos.to_s[0..0] }
      side==:white ? white_files : white_files.reverse
    end
    memoize :files

    def valid_position? pos
      return false unless pos
      pos = pos.to_sym unless Symbol===pos
      all_positions.include? pos.to_sym
    end
    memoize :valid_position?
  end
end

#Spread some knowledge around ! 
class String

  # black for a1 and b2, white for a8, etc..
  def square_color
    offset = (self[0]+self[1]) % 2
    offset == 0 ? :black : :white
  end

  def rank
    self[1..1].to_i
  end

  def file
    self[0..0]
  end

end # end monkeypatch String

module ChessSymbolExtensions
  def rank; @rank ||= self.to_s.rank ; end
  def file; @file ||= self.to_s.file ; end
  def back_rank
    @back_rank ||= case self
      when :white then '1'
      when :black then '8'
    end
  end
  def front_rank
    @front_rank ||= case self
      when :white then '2'
      when :black then '7'
    end
  end
  def castling_file
    @castling_file ||= case self
      when :queens then 'c'
      when :kings  then 'g'
    end
  end
  def opposite
    @opposite ||= case self
      when :white then :black
      when :black then :white
    end
  end
  # Lets you do d2 - d1 and get [0, -1]
  def - other
    self.to_s - other.to_s
  end
  # Lets you do d1 ^ [0, 1] and get d2
  def ^ other
    (self.to_s ^ other).to_sym
  end
end

Symbol.send(:include, ChessSymbolExtensions) unless Symbol.ancestors.include?(ChessSymbolExtensions)
