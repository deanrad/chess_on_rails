# Action Controller gives us the 3 unrelated methods: session, cookies, and params, all of which 
# simply are accessors over data which is either part of the body of the request, or pointed at
# in the case of session. I prefer to see these available as request.cookies, request.params, etc..
# and to extend the request object with other methods which abstract above all of those.
module RequestSmarts
  attr_accessor :session, :cookies, :params

  # the player this request is being processed for
  def current_player
    @current_player = player_in_session || player_in_cookie || player_over_http
  end
  alias :player :current_player

  # an already logged in player
  def player_in_session
    return nil unless session[:player_id] 
    Player.find(session[:player_id])
  end

  # authenticates from a stored md5 hash in a cookie
  def player_in_cookie
    return nil unless cookies[:auth_token]
    User.find_by_auth_token( cookies[:auth_token] ).playing_as
  end

  # provides basic auth for Curl/Wget functionality
  def player_over_http
    authenticate_with_http_basic do |username, password|
      User.find_by_email_and_security_phrase(username, password).playing_as
    end
  end
  
  # any http request is for only one match
  def match
    the_id = params[:id] || params[:match_id] 
    @match ||= if the_id
      the_id.to_i != 0 ? Match.find( the_id ) : Match.find_by_name( the_id )
    else
      Match.new
    end
  end

  def viewed_from_side
    return match.next_to_move if match.is_self_play?
    @viewed_from_side ||= (player == match.player1) ? :white : :black
  end

  def your_turn?
    @your_turn ||= viewed_from_side == match.next_to_move
  end
  alias :your_turn :your_turn?

  def last_move
    @last_move ||= match.moves.last
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
    env["REQUEST_URI"].include?("wml") or
    env["HTTP_REFERER"].include?("wml")
  end

  # if this request is coming from facebook- its been seen while testing match_controller_fb_spec
  # that sometimes facebook_session is nil in test mode. We'll extend the definition for now to
  # also allow for hacked-on fb_sig_user as well
  # def is_facebook?
  #   return false unless defined? facebook_session
  #   !! ( facebook_session || params[:fb_sig_user] )
  # end

  # # if accessed over facebook, the player referenced
  # def player_in_facebook
  #   fb_id = nil
  #   if defined? facebook_session
  #      fb_id = facebook_session ? facebook_session.user.id : params[:fb_sig_user]
  #   end
  #   return unless fb_id
  #   fbuser = Fbuser.find_by_facebook_user_id(fb_id)
  #   return fbuser.playing_as if fbuser
  # end

end
