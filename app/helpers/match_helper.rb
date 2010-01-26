module MatchHelper

  # The match the user is viewing or participating in.
  def match
    match_id = params[:id] || params[:match_id]
    @match ||= if match_id
      match_id.to_i != 0 ? Match.find( match_id ) : Match.find_by_name( match_idx )
    else
      Match.new    
    end
  end

  # The side of the current player in this match, or nil if the viewer is not
  # participating in this match.
  def current_player_side
    @current_player_side ||= case current_player
      when match.white; :white
      when match.black; :black
      else nil
    end
  end

  # The side from which this board is being viewed - white, for non-participants.
  def viewed_from_side; current_player_side || :white; end

  # Answers whether it is the turn of player watching to move next.
  def your_turn
    @your_turn ||= match.next_to_move == current_player_side; 
    rescue
    logger.error "Error computing next to move: #{match.inspect}, #{current_player.inspect}" and return nil
  end

  # Idiomatic alias for your_turn.
  alias :your_turn? :your_turn 

  # The board of this match, cached per-request for faster access.
  def board;      @board ||= match.board; end

  # For participants, the gameplay is the record associating them to this match,
  # and on which the move queue is stored, for example. See Gameplay.
  def gameplay;   @gameplay ||= match.gameplays[current_player_side]; end

  # The chat text lines associated with this match.
  def chats
    @chats ||= Chat.find_all_by_match_id(match.id, :include => :player)
  end

  # The last move made in this match.
  def last_move;  @last_move ||= match.moves.last; end

  # The number of moves made so far in this match.
  def move_count; @move_count ||= match.moves.count; end

  # Whether to render for downlevel browsers
  def downlevel?
    false # @downlevel ||= request.user_agent.downcase.include? 'berry'
  end

  # the sections to be shown on this page (currently only matches#index)
  def sections
    @sections ||= 
    [
     ["views.matches.index.sections.your_turn.title",
      lambda{|m| m.active? && m.player_to_move == current_player}
     ],
     ["views.matches.index.sections.their_turn.title",
      lambda{|m| m.active? && m.player_to_move != current_player}
     ],
     ["views.matches.index.sections.historical.title",
      lambda{|m| ! m.active? }
     ],
    ]
  end

  # checks for existance of .gif file in the current set's directory
  # if no .gif, uses .png extension
  def image_source_of( piece )
    "/images/sets/default/#{piece.img_name}.gif"
    match_session.set
    path = "/images/sets/#{session[:set]}/"
    extension = gif_file_exists?(piece, path) ? ".gif" : ".png"
    path + piece.img_name + extension
   end
  
  def gif_file_exists?(piece, path)
    File.exists?( Rails.public_path + path + piece.img_name + ".gif" )
  end

end
