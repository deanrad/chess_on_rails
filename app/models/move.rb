class Move < ActiveRecord::Base

  belongs_to :match
  before_save Proc.new{|me| raise ActiveRecord::ReadOnlyRecord unless me.new_record?}, 
              :update_computed_fields

  attr_accessor :side
  attr_reader   :board

  # Creates a new move, either the Rails way with a named hash, or a shorthand of the notation
  def initialize( opts )
    return super( :notation => "#{opts}" ) if String === opts || Symbol === opts

    super
  end

  # The board this move is being made against - set and read for validations
  def board
    @board ||= match.board
  end

  def before_validation
    return true unless new_record? #may have already been called by the association

    # Because of the stupid rails double-validation bug, we have to make sure we dont
    # validate against a future board. Instance-caching hopes to fix this
    @board ||= match.board

    #strip off to the move queue any portion of notation
    split_off_move_queue

    #determine coordinates from notation
    infer_coordinates_from_notation if !notation.blank? && (from_coord.blank? || to_coord.blank?)

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

  # Active Record callback to ensure validity of this chess move at this point in the game
  def validate
    # Got burned REAL bad by this bug. Just gonna fix cheap with this early exit. Don't want to make Match
    #   look look like :has_many :moves, :validate => false. But it really does matter in my case when
    #   validation is called, because the board is different. Damn you DHH !
    # 
    # https://rails.lighthouseapp.com/projects/8994/tickets/483-automatic-validation-on-has_many-should-not-be-performed-twice
    return unless new_record?

    if self[:from_coord].blank? && @possible_movers && @possible_movers.length > 1
      errors.add :notation, "Ambiguous move #{notation}. Clarify as in Ngf3 or R2d4, for example"
      return false
    end

    if self[:notation] && ( self[:from_coord].blank? || self[:to_coord].blank? )
      errors.add :notation, "The notation #{notation} doesn't specify a valid move" and return false
    end
    
    #ensure the validity of the coordinates we have whether specified or inferred
    [from_coord, to_coord].each do |coord|
      errors.add_to_base "#{coord} is not a valid coordinate" and return false unless Board.valid_position?( coord )
    end

    #verify allowability of the move
    errors.add_to_base "No piece present at #{from_coord} on this board" and return false unless @piece_moving

    unless @piece_moving.allowed_moves(@board).include?( to_coord.to_sym ) 
      errors.add_to_base "#{@piece_moving.function} not allowed to move to #{to_coord}" and return false
    end

    #can not leave your king in check at end of a move
    new_board=  @board.consider_move( Move.new( :from_coord => from_coord, :to_coord => to_coord ) )
    if new_board.in_check?( @piece_moving.side )
      errors.add_to_base "Can not place or leave one's own king in check - you may as well resign if you do that !" 
      return false
    end

  end

### notation methods ###
  NOTATION_TO_FUNCTION_MAP = { 'K' => :king, 'Q' => :queen,
                               'R' => :rook, 'N' => :knight, 'B' => :bishop  }

  # available to move model, sets fields on self based on self[:notation]
  # temporarily expands the castling notation to Kg2 
  # - if g2 is in K's allowed move list from it's from_coord then we're good
  def infer_coordinates_from_notation
    if notation.include?('O-O')
      file = notation.include?('O-O-O') ? 'c' : 'g'
      rank = match.next_to_move == :white ? '1' : '8'
      self.notation = "K#{file}#{rank}"
    end

    nofrills = notation.gsub('+','').gsub(/=./, '')
    self.to_coord = nofrills.gsub( /[#x!?]/, "")[-2,2]

    logger.info "infer_coordinates_from_notation: Inferred a move to #{to_coord} from notation: #{notation}"

    function = NOTATION_TO_FUNCTION_MAP[ notation[0,1] ] || :pawn

    @possible_movers = @board.select do |pos, piece| 
      piece.side == match.next_to_move && 
      piece.function == function && 
      piece.allowed_moves(@board).include?( self[:to_coord].to_sym )
    end

    self[:from_coord] = @possible_movers[0][0].to_s and return if @possible_movers.length == 1
    disambiguator = notation[-3,1]
    matcher = (disambiguator =~ /[1-8]/) ? Regexp.new( "^.#{disambiguator}$" ) : Regexp.new( "^#{disambiguator}.$" )
    movers = @possible_movers.select { |pos, piece| matcher.match(pos.to_s) }

    self[:from_coord] = movers[0][0].to_s and return if movers.length == 1
  end

  # Returns the notation for a given move - depends on alot of things - whether check was given, a capture made, etc..
  # - Prefer using file to disambiguate but use rank if file insufficient
  # - Most pieces have their piecetype abbreviation ( N for knight ), pawns have their file
  def notate
    # allow calling outside of activerecord lifecycle
    analyze_board_position unless @board

    mynotation = @piece_moving.abbrev.upcase.sub('P', from_coord.file)
    
    # disambiguate which piece moved if a 'sister_piece' could have moved there as well
    if( @piece_moving.function==:rook) || (@piece_moving.function==:knight)
      mynotation = mynotation.file

      sister_piece_pos, sister_piece = @board.sister_piece_of(@piece_moving)

      if( sister_piece != nil && sister_piece.allowed_moves(@board).include?(to_coord.to_sym) )
        mynotation += ( from_coord.file != sister_piece_pos.file) ? from_coord.file : from_coord.rank.to_s
      end
    end
        
    if @piece_moved_upon && (@piece_moving.side != @piece_moved_upon.side) || @board.en_passant_capture?( from_coord, to_coord )
      mynotation += 'x' 
      captured = true
    end

    #notate the destination square - a straight append except for noncapturing pawns
    mynotation = '' if( (@piece_moving.function==:pawn) && !captured )
    mynotation += to_coord
        
    #castling 3 O's if queenside otherwise 2 O's
    if castled == 1
      mynotation = 'O-O' + ((to_coord.file=='c') ? '-O' : '' ) 
    end

    #promotion
    if @piece_moving.function == :pawn && to_coord.to_s.rank == @piece_moving.promotion_rank
      self.promotion_choice ||= 'Q'
      mynotation += "=#{promotion_choice}"
    end
    
    #check/mate
    @board.consider_move(self) do |b|
      mynotation += '+' if b.in_check?( @piece_moving.side.opposite )
    end

    return mynotation
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
