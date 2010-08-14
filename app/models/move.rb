require 'notation'

class Move < ActiveRecord::Base
  include MoveNotation

  belongs_to :match
  belongs_to :player

  before_save :update_computed_fields
  after_save :notify_of_move_via_email

  attr_accessor :side
  attr_reader   :board

  def from_coord_sym; from_coord && from_coord.to_sym; end
  def to_coord_sym;   to_coord && to_coord.to_sym;     end

  def captured_piece_coord_sym
    @captured_piece_coord_sym = captured_piece_coord && captured_piece_coord.to_sym
  end

  # The board this move is being made against - set and read for validations
  def board; @board ||= match.board; end
  private :board

  def before_validation
    @board = match.board

    infer_coordinates_from_notation if !notation.blank? && (from_coord.blank? || to_coord.blank?)

    return unless from_coord

    @piece_moving = @board[from_coord]
    @piece_moved_upon = @board[to_coord]
  end

  #fields like the notation and whether this was a castling are stored with the move
  def update_computed_fields
    self.castled = 1 if (@piece_moving.function==:king && from_coord_sym.file=='e' && to_coord_sym.file =~ /[cg]/ )

    if ep = board.en_passant_capture?(from_coord_sym, to_coord_sym)
      self.captured_piece_coord = ep.to_s
    end

    self.notation = notate
    # self.player = match.opponent_of( match.send( match.next_to_move ) )
  end

  #stuff here depends on knowledge of the board's position prior to the move being committed
  # this should be considered a before-save function and maybe validate is not exactly the best place
  def validate
    return true if self.id  # saved moves are valid by definition

    if from_coord.blank? && @possible_movers && @possible_movers.length > 1
      errors.add :notation, "Ambiguous move #{notation}. Clarify as in Ngf3 or R2d4, for example"
      return 
    end

    if notation && ( from_coord.blank? || to_coord.blank? )
      errors.add :notation, "The notation #{notation} doesn't specify a valid move" and return 
    end
    
    #ensure the validity of the coordinates we have whether specified or inferred
    [from_coord, to_coord].each do |coord|
      errors.add_to_base "#{coord} is not a valid coordinate" unless Chess.valid_position?( coord )
    end

    #verify allowability of the move
    
    errors.add_to_base "No piece present at #{from_coord} on this board" and return if !@piece_moving

    unless @piece_moving.allowed_moves(@board).include?( to_coord.to_sym ) 
      errors.add_to_base "#{@piece_moving.function} not allowed to move to #{to_coord}" 
    end

    #can not leave your king in check at end of a move
    new_board=  @board.consider_move( Move.new( :from_coord => from_coord, :to_coord => to_coord ) )
    if new_board.in_check?( @piece_moving.side )
      errors.add_to_base "Can not place or leave one's own king in check - you may as well resign if you do that !" 
    end

  end

  # In the match passed, how long it has been
  def time_since_last_move( match )
    self.created_at - match.moves[ match.moves.index(self) - 1 ].created_at
  rescue
    # make sure we exceed this to trigger an email if we cant tell when they last moved
    ChessNotifier::MINIMUM_TIME_BETWEEN_MOVE_NOTIFICATIONS + 1.0/24
  end

private

  def notify_of_move_via_email
    # dont send email if its been less than 1/24 of a day
    # TODO move email blackout interval into configuration
    return unless self.time_since_last_move( self.match ) > ChessNotifier::MINIMUM_TIME_BETWEEN_MOVE_NOTIFICATIONS

    mover = self.player
    opponent = match.opponent_of(mover)
    ChessNotifier.deliver_opponent_moved(opponent, mover, self)
  rescue Exception => ex
    $stderr.puts ex.inspect
  end

end
