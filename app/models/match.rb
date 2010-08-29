class Match < ActiveRecord::Base
  
  has_many :players, :through    => :gameplays
  has_many :moves,   :before_add => :refer_to_match_instance,
                     :after_add  => [:save_board,
                                      :check_for_checkmate] 

  has_many :chats
  belongs_to :winning_player, :class_name => 'Player', :foreign_key => 'winning_player'

  named_scope :active,    :conditions => { :active => true }
  named_scope :completed, :conditions => { :active => false }

  # fetches the first and second joins to player, which are white,black respectively
  has_many :gameplays do
    def white; self[0]; end
    def black; self[1]; end
  end
  
  # the boards this match has known, in move order from the beginning
  def boards
    @boards ||= moves.inject([Chess.new_board]) do |all_boards, mv|
      all_boards << all_boards.last.clone.toggle_side_to_move!.play_move!(mv)
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
    white, black = players.first, players.last
    match = self.create(opts)

    # TODO switch gameplays if fen indicates you should
    match.gameplays << Gameplay.new(:player_id => white.id) 
    match.gameplays << Gameplay.new(:player_id => black.id, :black => true)
    
    if setup = opts[:start_pos] && ! setup.blank? && PGN::is_pgn?( setup )
      # TODO leave original PGN in start_pos, but ignore it (since its moves have been saved as move records)
      match.update_attribute(:start_pos, nil)

      pgn = PGN.new( setup )
      pgn.playback_against( match )
      logger.warn "Error #{pgn.playback_errors.to_a.inspect} in PGN playback of #{setup}" if pgn.playback_errors
    end
    match
  end

  def white
    @white ||= gameplays.white.player
  end

  def black
    @black ||= gameplays.black.player
  end

  def name
    self[:name] || lineup
  end

  # ensure that the match object instance used is ourselves
  def refer_to_match_instance( move )
    move.match = self
  end

  # cache this board and make it the most recent one
  def save_board( last_move )
    @boards << boards.last.clone.toggle_side_to_move!.play_move!( last_move )
  end

  def check_for_checkmate(last_move)
    me, other_guy =  last_move.side == :black ? [:black, :white] : [:white, :black]
    #checkmate_by( me ) if board.in_checkmate?( other_guy )
  end
    
  # for purposes of move validation it's handy to have access to such a variable
  def current_player
    side_to_move == :black ? self.black : self.white
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
  def side_to_move
    board.side_to_move
  end

  def side_of( plyr ) 
    return :white if plyr == self.white
    return :black if plyr == self.black
  end

  def lineup
    "#{white.name} vs. #{black.name}"
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
