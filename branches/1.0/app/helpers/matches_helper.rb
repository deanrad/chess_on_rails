#Contains functions for laying out the chess board
module MatchesHelper
  
  #iterates over the rows and yields columns in the correct order for rendering the board for white or black
  def positions_by_row_as( side )
    
    rows_in_order = []
    if side==:white
      0.upto(7){ |i| rows_in_order << i }
    else
      7.downto(0){ |i| rows_in_order << i } 
    end
    
    rows_in_order.each do |row_offset|
        from, to = [row_offset*8, row_offset*8 + 7]
        row_pieces = Position::POSITIONS[ (from..to) ]
        yield side==:white ? row_pieces : row_pieces.reverse
    end
    
  end
  
  def files_as( side )
    files = side==:white ? "abcdefgh" : "hgfedcba"
    files.each_byte{ |f| yield f.chr }
  end
  
  def side_of(match, player)
    return :white unless match and player
    match.player1 == player ? :white : :black
  end
  
  #returns the color of a square given a symbol or a string representing a position
  def square_color( pos )
    pos = pos.to_s
    (pos[0]+pos[1]) % 2 == 1 ? :white : :black
  end
  
  def render_piece( piece )
    return "&nbsp;" unless piece
  end
end
