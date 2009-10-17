module MatchHelper

  def match
    match_id = params[:id] || params[:match_id]
    @match ||= if match_id
      match_id.to_i != 0 ? Match.find( match_id ) : Match.find_by_name( match_idx )
    else
      Match.new # params[:match]?
    end
  end

  def board
    @board ||= match.board
  end

  def gameplay
    @gameplay = match.gameplays.send( viewed_from_side )
  end

  def chats
    @chats ||= Chat.find_all_by_match_id( params[:match_id] )
  end

  # TODO this should explicitly deal with non-logged in users
  def viewed_from_side
    @viewed_from_side ||= (current_player == match.player1) ? :white : :black
  end
  
  def your_turn
    @your_turn ||= match.send( match.next_to_move ) == current_player
  end

  def last_move
    @last_move ||= match.moves.last
  end

  def move_count
    @move_count ||= match.moves.count
  end

  def status_has_changed
    @status_has_changed ||= ( params[:move].to_i <= match.moves.length)
  end

  # the files, in order from the viewed_from_side for rendering
  def files
    @files ||= Board.files(viewed_from_side)
  end

  # the ranks, in order from the viewed_from_side for rendering (and reversed for HTML doc ordering)
  def ranks
    @ranks ||= Board.ranks(viewed_from_side).reverse
  end

  def chats
    @chats ||= Chat.find_all_by_match_id( match.id )
  end

  # checks for existance of .gif file in the current set's directory
  # if no .gif, uses .png extension
  def image_source_of( piece )
    "/images/sets/default/#{piece.img_name}.gif"
    session[:set] ||= 'default'
    path = "/images/sets/#{session[:set]}/"
    extension = gif_file_exists?(piece, path) ? ".gif" : ".png"
    path + piece.img_name + extension
   end
  
  def gif_file_exists?(piece, path)
    File.exists?( Rails.public_path + path + piece.img_name + ".gif" )
  end

end
