class Move < ActiveRecord::Base

  include MoveNotation

  ######### ActiveRecord Hooks  ##############################################

  belongs_to :match
  acts_as_list :column => :move_num, :scope => :match

  # Invokes our master validator method.
  validate :all_validations

  # The methods invoked by all_validations. An error detected at any point prevents
  # evaluation of the later methods. Default error keys are the method, prepended
  # with err_
  VALIDATIONS = [
     :coords_must_be_valid,
     :piece_must_be_present,
     :piece_must_allow_move,
  ]

  before_save :update_computed_fields

  ######### Properties and methods ###########################################

  # ActiveRecord fields:
  # :from_coord, :to_coord, :castled, :captured_move_coord, etc...

  # The board that existed at the time this move was made, also the board
  # against which it is validated.
  attr_accessor :board_before

  # The board as of the completion of this move
  attr_accessor :board_after

  # The side (black or white) making this move.  - TODO - is this used ? 
  # attr_accessor :side

  # Creates a new move, either the Rails way with a named hash, or a shorthand of the notation
  def initialize( opts )
    case opts; when String, Symbol
      super( :notation => "#{opts}" )
    else
      super
    end
  end

  # TODO make this true even when the match started from a start position (FEN) with
  # black first to move
  def side
    mynum = self.index
    return mynum % 2 == 0 ? :white : :black if mynum
    return match.moves.length % 2 == 0 ? :white : :black 
  end

  # The zero-based index of this move within the match
  def index;  @index  ||= match.moves.index(self);            end

  # The player making this move
  def player; @player ||= match.send( self.side );            end

  # The lazily-fetched piece involved in this move.
  def piece;    @piece ||= self.from_coord && self.board_before[ self.from_coord ]; end

  # The function (knight, rook, etc..) of the piece that is moving.
  def function; piece ? piece.function : "piece" ; end

  def capture?
    !! self[:captured_piece_coord]
  end

  ######### Before-validation methods  #######################################
  def only_create
    raise ActiveRecord::ReadOnlyRecord unless new_record?
  end

  ######### Validation Methods ###############################################
  # Invokes through our methods, but short-circuits if one returns false
  def all_validations #:nodoc:
    # $stderr.puts "all_validations: errors (#{errors.object_id}) empty ? #{errors.empty?}, new_record? #{new_record?}"

    return false unless errors.empty?
    VALIDATIONS.each do |v|
      result = send(v) ; return false unless errors.empty?
    end
  end

  def coords_must_be_valid
    [:from_coord, :to_coord].each do |coord|
      add_error coord, :"#{coord}_must_be_valid" unless Board.valid_position?( send(coord) )
    end
  end

  def piece_must_be_present
    add_error(:from_coord, :piece_must_be_present) unless piece
  end

  def piece_must_allow_move
    add_error(:to_coord, :piece_must_allow_move) unless begin
      piece.allowed_moves(self.board_before).include? self.to_coord.to_sym
    end
  end


  ######### Before-save Methods ##############################################
  def update_computed_fields
    # Take the board the way it was before me and play me upon it
    self.board_after = self.board_before.dup.play_move!( self )

    # TODO this will need to be updated to read: 'if any of the opponents pieces are missing...'
    unless board_before.size == board_after.size
      self.captured_piece_coord ||= self[:to_coord]
    end

    self[:notation] = SAN.from_move(self) # always renotate the move to canonicalize it
    self[:castled] = 1 if piece && (piece.function==:king && from_coord.file=='e' && to_coord.file =~ /[cg]/ )
  end

  ######### After-save Methods ###############################################


  ######### Error Module Methods #############################################

  # Declares fields which will be looked-up on instances of this object for 
  # use in interpolating error messages.
  ERROR_FIELDS = [:from_coord, :to_coord, :notation, :function]

  # Looks up ERROR_FIELDS on self to create a hash of fields-to-values, and 
  # merges an optional hash_to_merge, to create a hash of interpolatable
  # strings to I18n
  def t key, hash_to_merge = {} #:nodoc:
    interpol = ERROR_FIELDS.inject({}){ |h,v| h[v] = self.send(v) rescue ''; h }
    interpol.merge!(hash_to_merge)
    I18n.t key, interpol
  end

  # invokes errors.add and evaluates to false
  def add_error field, validation
    errors.add( field, (t :"errors.#{validation}") ) and return false
  end

end
