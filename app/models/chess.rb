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
        @@pieces << Piece.new( side, "#{file}_pawn", file + front_rank )
      end

      @@pieces << Piece.new( side, :queens_rook, 'a'+back_rank )
      @@pieces << Piece.new( side, :queens_knight, 'b'+back_rank )
      @@pieces << Piece.new( side, :queens_bishop, 'c'+back_rank )
      @@pieces << Piece.new( side, :queen, 'd'+back_rank )
      @@pieces << Piece.new( side, :king, 'e'+back_rank )
      @@pieces << Piece.new( side, :kings_bishop, 'f'+back_rank )
      @@pieces << Piece.new( side, :kings_knight, 'g'+back_rank )
      @@pieces << Piece.new( side, :kings_rook, 'h'+back_rank )

    end

    return @@pieces
  end
  
end
