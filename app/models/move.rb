require 'notation'

class Move < ActiveRecord::Base
  include MoveNotation

  belongs_to :match
  before_save Proc.new{|me| raise ActiveRecord::ReadOnlyRecord unless me.new_record?}, 
              :update_computed_fields

  attr_accessor :side
  attr_reader   :board

  # Creates a new move, either the Rails way with a named hash, or a shorthand of the notation
  def initialize( opts )
    return super( :notation => "#{opts}" ) if String === opts || Symbol === opts

    super
    if self[:notation].blank? == ( self[:from_coord].blank? && self[:to_coord].blank? )
      raise 'Please only attempt to specify a notation, or a from/to coordinate pair.' 
    end
  end

  # The board this move is being made against - set and read for validations
  def board
    @board ||= match.board
  end
  private :board

  def before_validation
    return true unless new_record? #may have already been called by the association

    # Because of the stupid rails double-validation bug, we have to make sure we dont
    # validate against a future board. Instance-caching hopes to fix this
    @board ||= match.board

    #strip off to the move queue any portion of notation
    split_off_move_queue

    #determine coordinates from notation
    infer_coordinates_from_notation if !self[:notation].blank? && (from_coord.blank? || to_coord.blank?)

    # validations will get us later
    return false unless from_coord

    @piece_moving = @board[from_coord]
    @piece_moved_upon = @board[to_coord]
    
    true
  end

  # Turns start at one and encompasss two moves each
  def turn
    @turn ||= (self.match.moves.index( self ) + 2) / 2
  end  

  #fields like the notation and whether this was a castling are stored with the move
  def update_computed_fields
    #enpassant
    if @board.en_passant_capture?( from_coord, to_coord )
      self[:captured_piece_coord] = to_coord.gsub( /3/, '4' ).gsub( /6/, '5' )
    end

    #castling
    self[:castled] = 1 if (@piece_moving.function==:king && from_coord.file=='e' && to_coord.file =~ /[cg]/ )

    #finally ensure move is (re)notated
    self[:notation] = notate
  end

  def validate
    # Got burned REAL bad by this bug. Just gonna fix cheap with this early exit. Don't want to make Match
    #   look look like :has_many :moves, :validate => false. But it really does matter in my case when
    #   validation is called, because the board is different. Damn you DHH !
    # 
    # https://rails.lighthouseapp.com/projects/8994/tickets/483-automatic-validation-on-has_many-should-not-be-performed-twice
    return unless new_record?

    if self[:from_coord].blank? && @possible_movers && @possible_movers.length > 1
      errors.add :notation, "Ambiguous move #{notation}. Clarify as in Ngf3 or R2d4, for example"
      return 
    end

    if self[:notation] && ( self[:from_coord].blank? || self[:to_coord].blank? )
      errors.add :notation, "The notation #{notation} doesn't specify a valid move" and return 
    end
    
    #ensure the validity of the coordinates we have whether specified or inferred
    [from_coord, to_coord].each do |coord|
      errors.add_to_base "#{coord} is not a valid coordinate" unless Chess.valid_position?( coord )
    end

    #verify allowability of the move
    errors.add_to_base "No piece present at #{from_coord} on this board" and return unless @piece_moving

    unless @piece_moving.allowed_moves(@board).include?( to_coord.to_sym ) 
      errors.add_to_base "#{@piece_moving.function} not allowed to move to #{to_coord}" and return
    end

    #can not leave your king in check at end of a move
    new_board=  @board.consider_move( Move.new( :from_coord => from_coord, :to_coord => to_coord ) )
    if new_board.in_check?( @piece_moving.side )
      errors.add_to_base "Can not place or leave one's own king in check - you may as well resign if you do that !" 
    end

  end

private

  def split_off_move_queue
    return if self[:notation].blank?

    all_moves = self[:notation].split /[,; ]/

    self[:notation] = all_moves.shift

    return if all_moves.length == 0 #no move queue
    
    with match.gameplays.send( match.next_to_move ) do |gp|
      gp.update_attribute( :move_queue, all_moves.join(' ') )
    end
  end
  
end
