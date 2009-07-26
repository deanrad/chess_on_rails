require 'piece/king'
require 'piece/queen'
require 'piece/knight'
require 'piece/rook'
require 'piece/bishop'
require 'piece/pawn'

class Chess 	

  FILES = "abcdefgh"
  RANKS = "12345678"

  def self.valid_position?(pos)
    return false unless pos && pos.length == 2
    return false unless FILES.include?(pos[0]) && RANKS.include?(pos[1])
    
    true
  end

  def self.initial_pieces
    
    @@pieces = []
    
    [ :white, :black ].each do |side|

      ('a'..'h').each do |file|
        @@pieces << [ Pawn.new( side, :"#{file}") , file + side.front_rank ]
      end

      @@pieces << [ Rook.new(side, :queens)   , "a#{side.back_rank}" ]
      @@pieces << [ Knight.new(side, :queens) , "b#{side.back_rank}" ]
      @@pieces << [ Bishop.new(side, :queens) , "c#{side.back_rank}" ]
      @@pieces << [ Queen.new(side )          , "d#{side.back_rank}" ]
      @@pieces << [ King.new(side )           , "e#{side.back_rank}" ]
      @@pieces << [ Bishop.new(side, :kings)  , "f#{side.back_rank}" ]
      @@pieces << [ Knight.new(side, :kings)  , "g#{side.back_rank}" ]
      @@pieces << [ Rook.new(side, :kings)    , "h#{side.back_rank}" ]

    end

    return @@pieces
  end
  
end
