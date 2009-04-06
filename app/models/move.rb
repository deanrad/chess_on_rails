require 'notation'

class Move < ActiveRecord::Base
  include MoveNotation

  belongs_to :match

  attr_accessor :side

  before_save :update_computed_fields

  def initialize( opts )
    super
    if self[:notation].blank? == ( self[:from_coord].blank? && self[:to_coord].blank? )
      raise 'Please only attempt to specify a notation, or a from/to coordinate pair.' 
    end
  end

  def before_validate
    @board = match.board

    #determine coordinates from notation
    infer_coordinates_from_notation if !self[:notation].blank? && (from_coord.blank? || to_coord.blank?)

    # validations will get us later
    return unless from_coord

    @piece_moving = @board[from_coord]
    @piece_moved_upon = @board[to_coord]
  end

  #fields like the notation and whether this was a castling are stored with the move
  def update_computed_fields
    #enpassant
    if @board.is_en_passant_capture?( from_coord, to_coord )
      self[:captured_piece_coord] = to_coord.gsub( /3/, '4' ).gsub( /6/, '5' )
    end

    #promotion
    self[:promotion_choice] ||= 'Q' if @piece_moving.promotable?( to_coord[1].chr )

    #castling
    self[:castled] = 1 if (@piece_moving.type==:king && from_coord[0].chr=='e' && ['c','g'].include?( to_coord[0].chr ) )

    #finally ensure move is notated
    self[:notation] = notate
  end

  #stuff here depends on knowledge of the board's position prior to the move being committed
  # this should be considered a before-save function and maybe validate is not exactly the best place
  def validate

    errors.add :notation, "Ambiguous move #{notation}" and return if @possible_movers && @possible_movers.length > 1
    
    if self[:notation] && ( self[:from_coord].blank? || self[:to_coord].blank? )
      errors.add :notation, "The notation #{notation} doesn't specify a valid move" and return 
    end
    
    #ensure the validity of the coordinates we have whether specified or inferred
    [from_coord, to_coord].each do |coord|
      errors.add_to_base "#{coord} is not a valid coordinate" unless Chess.valid_position?( coord )
    end

    if @possible_movers && @possible_movers.length==0
      errors.add :to_coord, "No piece capable of moving to #{self[:to_coord]} on this turn" and return 
    end

    #verify allowability of the move
    
    errors.add_to_base "No piece present at #{from_coord} on this board" and return if !@piece_moving

    unless @piece_moving.allowed_moves(@board, from_coord).include?( to_coord ) 
      errors.add_to_base "#{@piece_moving.role} not allowed to move to #{to_coord}" 
    end

    #can not leave your king in check at end of a move
    new_board=  @board.consider_move( Move.new( :from_coord => from_coord, :to_coord => to_coord ) )
    if new_board.in_check?( @piece_moving.side )
      errors.add_to_base "Can not place or leave one's own king in check - you may as well resign if you do that !" 
    end

  end

  
end
