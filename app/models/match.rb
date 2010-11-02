class Match < ActiveRecord::Base
  
  has_many :players, :through    => :gameplays
  has_many :moves

  has_many :chats
  belongs_to :winner, :class_name => 'Player', :foreign_key => 'winning_player'

  default_scope :include => :gameplays
  
  named_scope :active,    :conditions => { :active => 1 }
  named_scope :completed, :conditions => { :active => 0 }

  # fetches the first and second joins to player, which are white,black respectively
  has_many :gameplays do
    def white; self[0]; end
    def black; self[1]; end
  end
  
  def initial_board
    @initial_board ||= start_pos.blank? ? Chess.new_board : Fen.new(start_pos).parse
  end

  def reload; super; @boards = nil; self; end
  
  # the boards this match has known, in move order from the beginning
  def boards
    @boards ||= moves.inject([ self.initial_board ]) do |all_boards, mv|
      all_boards << all_boards.last.dup.toggle_side_to_move!.play_move!(mv)
    end
  end

  # the most recent board known
  def board
    boards.last
  end

  # Returns a saved, started match. 
  # Match.start!( :players => [white, black], :start_pos => fen_or_pgn_or_nil )
  def self.start!( opts={} )
    players=opts.delete(:players)
    raise ArgumentError unless players && players.length == 2 && ! players.include?(nil)
    white, black = players.first, players.last
    match = self.create(opts)

    # TODO switch gameplays if fen indicates you should
    match.gameplays << Gameplay.new(:player_id => white.id) 
    match.gameplays << Gameplay.new(:player_id => black.id, :black => true)
    
    if setup = opts[:start_pos] && ! setup.blank?
      if PGN::is_pgn?( setup )
        # TODO leave original PGN in start_pos, but ignore it (since its moves have been saved as move records)
        match.update_attribute(:start_pos, nil)

        pgn = PGN.new( setup )
        pgn.playback_against( match )
        logger.warn "Error #{pgn.playback_errors.to_a.inspect} in PGN playback of #{setup}" if pgn.playback_errors
      elsif fen=Fen.new(setup) && fen.parse
        
      end
    end
    match
  end

  def white
    @white ||= gameplays.white && gameplays.white.player
  end

  def black
    @black ||= gameplays.black && gameplays.black.player
  end

  def name
    self[:name] || "#{white.name} vs. #{black.name}"
  end
  
  def outcome
    return "In Progress" if self.active? 
    case self.result
    when "Checkmate"
      "Checkmate by #{winner.name}"
    when "Resigned"
      "Resigned. Winner #{winner.name}"
    end
  end

  def is_self_play? 
    @self_play ||= (self.white == self.black) 
  end
  
  def turn_of? player 	
    return true if self.white == player && self.side_to_move == :white
    return true if self.black == player && self.side_to_move == :black
    false
  end

  # Returns the symbol :white or :black of the next to move in this match
  def side_to_move( method = :length )
    s = initial_board.side_to_move
    moves.send(method) % 2 == 0 ? s : s.opposite
  end

  def side_of( plyr ) 
    return :white if plyr.id == gameplays.white.player_id
    return :black if plyr.id == gameplays.black.player_id
  end

  def resign( plyr )
    self.result, self.active = ['Resigned', 0]
    self.winning_player = (plyr == white) ? black : white
    save!
  end

  def checkmate_by( side )
    self.reload
    self.result, self.active = ['Checkmate', 0]
    self.winning_player = (side == :white ? white : black )
    save!
  end

  def moves_more_recent_than( move_id )
    return moves if move_id.nil? || move_id == 0
    moves.select{ |mv| mv.id > move_id }
  end
  
  def chats_more_recent_than( chat_id )
    return chats if chat_id.nil? || chat_id == 0
    chats.select{ |c| c.id > chat_id }
  end
  
  private
=begin
  # if moves are queued up, looks for matches and plays appropriate responses, or invalidates queue
  # for now requires exact match on the notation
  def play_queued_moves( m )
    opponent = m.match.gameplays.send( m.match.side_to_move )
    queue = opponent.move_queue
    return unless queue.length > 1

    expected, response = queue.shift(2)
    
    if expected != m.notation
      logger.debug "Pruning move queue due to incorrect prediction"
      opponent.update_attribute(:move_queue, nil) and return 
    end

    logger.debug "Making queued move #{response}"
    # and make the response move - because we go direct, we can't rely on
    # automatic calling of the callback to continue evaluating queues - bumr !
    response_move = Move.create(:match_id => self.id, :notation => response)

    logger.debug "Writing back remainder of move queue: #{queue.to_s}"
    opponent.update_attribute(:move_queue, queue.to_s)

    # call it back
    play_queued_moves(response_move)
  end
=end

end
