require 'notation'

class Move < ActiveRecord::Base
  include MoveNotation

  belongs_to :match
  belongs_to :player

  before_save :update_computed_fields

  attr_accessor :side
  attr_reader   :board

  def from_coord_sym; from_coord && from_coord.to_sym; end
  def to_coord_sym;   to_coord && to_coord.to_sym;     end

  def captured_piece_coord_sym
    @captured_piece_coord_sym = captured_piece_coord && captured_piece_coord.to_sym
  end

  # The board this move is being made against - set and read for validations
  def board
    @board ||= match.board
  end
  
  # The match this move is being made against - the exact instance
  def match
    return @match if @match
    ObjectSpace.each_object(Match) do |m| 
      @match=m if m.id == match_id
    end
    @match ||= Match.find(match_id)
  end

  def before_validation
    @board = match && match.board
    return unless @board 

    infer_coordinates_from_notation if !notation.blank? || from_coord.blank? || to_coord.blank?

    return if from_coord.blank? || to_coord.blank?
    @piece_moving = @board[from_coord]
    @piece_moved_upon = @board[to_coord]


    if @board.en_passant_square == self.to_coord_sym
      coord = @board.en_passant_square ^ ( @piece_moving.side == :white  ? [0,-1]  : [0,1] )
      self.captured_piece_coord = coord.to_s if @piece_moving.function == :pawn
    end

  end

  #fields like the notation and whether this was a castling are stored with the move
  def update_computed_fields
    self.castled = 1 if (@piece_moving.function==:king && from_coord_sym.file=='e' && to_coord_sym.file =~ /[cg]/ )
    self.notation = notate
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
      errors.add :notation, "The notation #{notation} doesn't specify a valid move for #{match.side_to_move} on this board." and return 
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
      errors.add_to_base "Cannot leave ones own king in check" 
    end

  end
  
  def friendly_time
    self.created_at && self.created_at.strftime("%a %H:%M")
  end

  def time_since_last_move
    self.created_at - match.moves[ match.moves.index(self) - 1 ].created_at
  rescue
    # make sure we exceed this to trigger an email if we cant tell when they last moved
    ChessNotifier::MINIMUM_TIME_BETWEEN_MOVE_NOTIFICATIONS + 1.0/24
  end
  
  def to_json
    h = {
      # TODO include index/plycount
      'id' => self.id,
      'notation' => self.notation,
      'friendly_time' => self.friendly_time,
      'from_coord' => self.from_coord,
      'to_coord' => self.to_coord
    }
    h['errors'] = self.errors.full_messages.join(". ") unless self.errors.blank?
    h.to_json
  end

end
