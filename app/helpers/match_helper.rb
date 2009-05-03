module MatchHelper

  def match
    @match ||= if params[:id] 
      Match.find( params[:id] )
    else
      Match.new # params[:match]?
    end
  end

  # checks for existance of .gif file in the current set's directory
  # if no .gif, uses .png extension
  def image_source_of( piece )
    "/images/sets/default/#{piece.role.to_s}_#{piece.side.to_s[0,1]}.gif"
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

  def board
    @board ||= match.board
  end

  def viewed_from_side
    @viewed_from_side ||= (current_player == match.player1) ? :white : :black
  end

  def your_turn
    @your_turn ||= match.turn_of?( current_player )
  end

  def last_move
    @last_move ||= match.moves.last
  end

  def status_has_changed
    @status_has_changed ||= ( params[:move].to_i <= match.moves.length)
  end

  # the files, in order from the viewed_from_side for rendering
  def files
    @files ||= (viewed_from_side == :black) ? Chess::Files.reverse : Chess::Files
  end

  # the ranks, in order from the viewed_from_side for rendering
  def ranks
    @ranks ||= (viewed_from_side == :black) ? Chess::Ranks : Chess::Ranks.reverse
  end

  def move_queue
    match.gameplays.send(match.side_of(current_player)).move_queue
  end

end
