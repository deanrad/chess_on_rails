# Action Controller gives us the 3 unrelated methods: session, cookies, and params, all of which 
# simply are accessors over data which is either part of the body of the request, or pointed at
# in the case of session. I prefer to see these available as request.cookies, request.params, etc..
# and to extend the request object with other methods which abstract above all of those.
module RequestSmarts
  attr_accessor :session, :cookies, :params
  attr_accessor :player

  # an already logged in player
  def player_in_session
    return nil unless session[:player_id] 
    Player.find(session[:player_id])
  end

  # authenticates from a stored md5 hash in a cookie
  def player_in_cookie
    return nil unless cookies[:auth_token]
    return nil unless u = User.find_by_auth_token( cookies[:auth_token] )
    u.playing_as
  end

  def player
    player_in_session || player_in_cookie
  end
  def player= p
    session[:player_id] = p.id
  end

  def opponent( match = self.match)
    return match.black if match.white == self.player 
    return match.white if match.black == self.player 
  end

  # any http request is for only one match
  def match
    the_id = params[:id] || params[:match_id] 
    @match ||= if the_id
      the_id.to_i != 0 ? Match.find( the_id, :include => [:chats, :moves] ) : Match.find_by_name( the_id )
    else
      Match.new
    end
  end
  
  def chats
    @chats ||= Chat.find_all_by_match_id( match.id, :include => :player )
  end

  def viewed_from_side
    return match.side_to_move if match.is_self_play?
    @viewed_from_side ||= (player == match.white) ? :white : :black
  end

  def your_turn?
    @your_turn ||= (viewed_from_side == (match.id && match.side_to_move))
  end
  alias :your_turn :your_turn?

  def last_move
    @last_move ||= match.moves.last
  end

  def last_chat
    @last_chat ||= match.chats.last
  end

  def board
    @board ||= match.board
  end

  # the files, in order from the viewed_from_side for rendering
  def files
    @files ||= Chess.files(viewed_from_side)
  end

  # the ranks, in order from the viewed_from_side for rendering
  def ranks
    @ranks ||= Chess.ranks(viewed_from_side)
  end

  # when polling, indicates whether there is new information to send to the client
  def status_has_changed
    @status_has_changed ||= ( params[:move].to_i <= match.moves.length)
  end

  def mobile?
    env["REQUEST_URI"].include?("wml") || (env["HTTP_REFERER"] || '').include?("wml")
  end

end
