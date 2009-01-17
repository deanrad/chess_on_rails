#Contains functions for laying out the chess board
module MatchesHelper
  
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

  # checks for existance of .gif file in the current set's directory
  # if no .gif, uses .png extension
  def image_source_of( piece )
    session[:set] ||= 'default'
    path = "/images/sets/#{session[:set]}/"
    extension = gif_file_exists?(piece, path) ? ".gif" : ".png"
    path + piece_file_name(piece) + extension
  end
  
  def piece_file_name(piece)
    "#{piece.role.to_s}_#{piece.side.to_s[0,1]}"
  end
  
  def gif_file_exists?(piece, path)
    File.exists?( Rails.public_path + path + piece_file_name(piece) + ".gif" )
  end
  
end
