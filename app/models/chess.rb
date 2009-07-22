require 'piece/king'
require 'piece/queen'
require 'piece/knight'
require 'piece/rook'
require 'piece/bishop'
require 'piece/pawn'

class Chess 	

  Files = "abcdefgh"
  Ranks = "12345678"

  def self.valid_position?(pos)
    return false unless pos and pos.length == 2
    return false unless Files.include? pos[0] and Ranks.include? pos[1]
    
    return true
  end

  def self.initial_pieces
    
    @@pieces = []
    
    [ [:white, '1', '2'], [:black, '8', '7'] ].each do |side, back_rank, front_rank|

      ('a'..'h').each do |file|
        @@pieces << [ Pawn.new( side, :"#{file}") , file + front_rank ]
      end

      @@pieces << [ Rook.new(side, :queens)   , 'a'+back_rank ]
      @@pieces << [ Knight.new(side, :queens) , 'b'+back_rank ]
      @@pieces << [ Bishop.new(side, :queens) , 'c'+back_rank ]
      @@pieces << [ Queen.new(side )          , 'd'+back_rank ]
      @@pieces << [ King.new(side )           , 'e'+back_rank ]
      @@pieces << [ Bishop.new(side, :kings)  , 'f'+back_rank ]
      @@pieces << [ Knight.new(side, :kings)  , 'g'+back_rank ]
      @@pieces << [ Rook.new(side, :kings)    , 'h'+back_rank ]

    end

    return @@pieces
  end
  
end
