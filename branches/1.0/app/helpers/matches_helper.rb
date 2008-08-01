#Contains functions for laying out the chess board
module MatchesHelper
  
  #TODO allow swapping of sets by changing this up, and hiding extension - basically making image controller
  IMG_ROOT_PATH = '/images/sets/default/'
  
  #iterates over the rows and yields columns in the correct order for rendering the board for white or black
  def positions_by_row_as( side )
    

    rows_in_order = (side == :white) ? (0..7) : (0..7).to_a.reverse
    
    rows_in_order.each do |row_offset|
        from, to = [row_offset*8, row_offset*8 + 7]
        row_pieces = Position::POSITIONS[ (from..to) ]
        yield side==:white ? row_pieces : row_pieces.reverse
    end
    
  end
  
  #an iterator over files that goes in the correct order for the side viewing
  def files_as( side )
    files = side==:white ? "abcdefgh" : "hgfedcba"
    files.each_byte{ |f| yield f.chr }
  end
  
  #lets the view query which side the current player is on
  #TODO allow the user to turn the board around
  def side_of(match, player)
    return :white unless match and player
    match.player1 == player ? :white : :black
  end
  
  #returns the color of a square given a symbol or a string representing a position
  def square_color( pos )
    pos = pos.to_s
    (pos[0] + pos[1]) % 2 == 1 ? :white : :black
  end

  #Shows a piece  
  #REFACTOR this may be best as a partial
  def render_piece( position, board )
    piece = board[position.to_sym]
    return "&nbsp;" unless piece
    moves = board.allowed_moves(position.to_sym) * ' '
    "<img src='#{IMG_ROOT_PATH}#{piece.role}_#{piece.side.to_s[0,1]}.gif' alt='' class='piece #{moves}'/>"
  end
end
