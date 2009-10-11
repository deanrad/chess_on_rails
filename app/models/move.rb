class Move < ActiveRecord::Base

  ######### ActiveRecord Hooks  ##############################################

  belongs_to :match

  # Invokes our master validator method.
  validate :all_validations

  # The methods invoked by all_validations. An error detected at any point prevents
  # evaluation of the later methods. Default error keys are the method, prepended
  # with err_
  VALIDATIONS = [
     :piece_must_be_present,
     :piece_must_allow_move,
  ]

  # Fields exported for use in error messages.
  ERROR_FIELDS = [:from_coord, :to_coord, :notation, :function]

  before_save :update_computed_fields


  ######### Properties and methods ###########################################

  # ActiveRecord fields:
  # :from_coord, :to_coord, :castled, :captured_move_coord, etc...

  # The lazily-fetched most recent board of the match, against which this move
  # is validated.
  def board; @board ||= match.board; end

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

  # Turns start at one and encompasss two moves each
  def turn
    @turn ||= (self.match.moves.index( self ) + 2) / 2
  end  

  # The lazily-fetched piece involved in this move.
  def piece;    @piece ||= self.board[ self.from_coord ]; end

  # The function (knight, rook, etc..) of the piece that is moving.
  def function; piece ? piece.function : "piece" ; end


  ######### Before-validation methods  #######################################
  def only_create
    raise ActiveRecord::ReadOnlyRecord unless new_record?
  end

  ######### Validation Methods ###############################################
  # Invokes through our methods, but short-circuits if one returns false
  def all_validations #:nodoc:
    VALIDATIONS.each do |v|
      result = send(v) ; return false unless errors.empty?
    end
  end

  def piece_must_be_present
    add_error(:from_coord, :piece_must_be_present) unless piece
  end

  def piece_must_allow_move
    add_error(:to_coord, :piece_must_allow_move) unless begin
      piece.allowed_moves(self.board).include? self.to_coord.to_sym
    end
  end

  ######### Before-save Methods ##############################################
  def update_computed_fields
    self[:castled] = 1 if (piece.function==:king && from_coord.file=='e' && to_coord.file =~ /[cg]/ )
  end

  ######### After-save Methods ###############################################


  ######### Helper Methods ###################################################
  # provides interpolation options a hash of :to_coord => 'f2' for example
  def t key, *args #:nodoc:
    # I18n.t key, (ERROR_FIELDS.inject({}){ |h,v| h[v] = self.send(v) }
    I18n.t key, ERROR_FIELDS.inject({}){ |h,v| h[v] = self.send(v); h }
  end

  # invokes errors.add and evaluates to false
  def add_error field, validation
    errors.add( field, (t :"err_#{validation}") ) and return false
  end
end
