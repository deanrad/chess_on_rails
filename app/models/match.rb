class Match < ActiveRecord::Base
  
  # A gameplay record is a (eventually versioned) players' personal stash of data about the match
  # This includes their move_queue, their offers to draw, etc..
  has_many :players, :through    => :gameplays

  # The moves of this match. Before we add one, we ensure that it has a direct 
  # reference to this match instance, so it can use our history to validate.
  # After adding we store the new board instance, check for checkmate, and store any move queue
  has_many :moves,   :order => 'move_num',
                     :include => :match,
                     :before_add => :set_pre_board_on_move,
                     :after_add  => :get_post_board_from_move
  
  belongs_to :winning_player, :class_name => 'Player', :foreign_key => 'winning_player'
                     
  named_scope :active,    :conditions => { :active => 1 }
  named_scope :completed, :conditions => { :active => 0 }

  # Defines the relations between the players involved, and this match, 
  has_many :gameplays do
    def[] sym
      case sym when :white; self[0]; when :black; self[1]; else super; end
    end
  end

  # Shortcut method for making move in console: m << "Nc5"
  def << notation; self.moves << Move.new(:notation => notation); end

  #################### Instance Methods #############
  def initialize( opts={} )
    white, black = opts.delete(:players) if opts[:players]
    super
    # saving of self triggered by below
    gameplays << Gameplay.new(:player_id => white.id, :black => false) if white
    gameplays << Gameplay.new(:player_id => black.id, :black => true ) if black
  end

  # The first gameplay record is player1 aka white, and the second is player2 aka black
  def white;  @player1 ||= gameplays[:white].player ; end ;    alias :player1 :white  
  def black;  @player2 ||= gameplays[:black].player ; end ;    alias :player2 :black

  # Answers whether the object passed is a player in this match
  def is_playing? plyr
    plyr == self.player1 || plyr == self.player2
  end

  # Called by before_add
  def set_pre_board_on_move mv
    mv.board_before = self.board
  end

  # Called by after_add
  def get_post_board_from_move mv
    self.boards << mv.board_after
  end

  # The current state of the board for this match
  def board
    unless @boards && @boards.size == moves.length
      #b = boards(true) # force recalc
    end
    boards.last
  end

  # An array of boards of length moves.length+1 (including initial board)
  def boards(force_recalc = false)
    return @boards if @boards && ! force_recalc

    # logger.info "calculating boards for match #{self.id}"

    # we have a new board (in initial position)
    @boards = [Board.new]

    # and for each move
    moves.each do |mv|
      # we have a new board, which is a dup of old one ..
      new_board = @boards.last.dup
      @boards << new_board

      # .. but with this new move played upon it
      new_board.play_move!(mv) if mv.errors.empty?
    end

    @boards
  end

  # The friendly name of this match, Player1 vs. Player2 by default.
  def name
    self[:name] || "#{player1.name} vs. #{player2.name}"
  end

  # Cache this board and make it the most recent one
#  def save_board( last_move )
#    $stderr.puts "#{last_move.infer_coordinates_from_notation} #{last_move.valid?}"
#    return false unless last_move.infer_coordinates_from_notation && last_move.valid?
#    last_move.board_after = self.board.dup.play_move!( last_move )
#    self.boards.store( @boards.keys.max + 1, self.board_after )
#  end

  # as long as the game starts at the beginning, white goes first
  def first_to_move
    return :white if self[:start_pos].blank?
    @first_to_move ||= Board.new( self[:start_pos] ).next_to_move
  end

  # the next_to_move alternates sides each move (technically every half-move)
  def next_to_move
    moves.length.even? ? first_to_move : first_to_move.opposite
  end
  alias :side_to_move :next_to_move

  # the player next to move
  def player_to_move
    self.send(self.next_to_move)
  end

  def resign( plyr )
    self.result, self.active = ['Resigned', 0]
    self.winning_player = (plyr == player1) ? player2 : player1
    save!
  end

=begin
  # if moves are queued up, looks for matches and plays appropriate responses, or invalidates queue
  # for now requires exact match on the notation
  # TODO this should move to plugin and be rewritten
  def play_queued_moves( m )
    opponent = m.match.gameplays[ m.match.next_to_move == :white ? 1 : 0 ] 
    return unless opponent && opponent.move_queue.length > 1

    queue = MoveQueue.new(queue) unless MoveQueue === queue

    unless queue.hit?(actual = m)
      opponent.update_attribute(:move_queue, nil) and return 
    end

    # and make the response move - because we go direct, we can't rely on
    # automatic calling of the callback to continue evaluating queues - bumr !
    expected, response = queue.shift, queue.shift
    response_move = Move.create(:match_id => self.id, :notation => response)

    opponent.update_attribute(:move_queue, queue.to_s)

    # call it back from other side (continues until queue.hit? returns false)
    play_queued_moves(response_move)
  end
=end

  # Handy instance cache of AR objects - go through Match[id] and you're guaranteed
  # to get a process-level-cached instance of that AR object. Note that when 
  # config.cache_classes = false, as is often the case in development environment,
  # the autoloader will do loads more often and class variables will disappear, thus
  # making global variables the choice for a process-wide cache.
  def self.matches
    ActiveSupport::Dependencies.mechanism == :load ? ($MATCHES||={}) : (@@matches||={})
  end

  # Implements a concise syntax for find, and allows callers to grab
  # a canonical object instance for a given DB record.
  def self.[] id
    matches[id.to_i] ||= Match.find(id, :include => [:gameplays, :players, :moves])
  end
end
