class Move < ActiveRecord::Base
  belongs_to :match

  attr_accessor :side
  before_validation :analyze_board_position
  before_save :update_computed_fields

  NOTATION_TO_ROLE_MAP = { 'R' => 'rook', 'N' => 'knight', 'B' => 'bishop', 'Q' => 'queen', 'K' => 'king' }

  def initialize( opts )
    super
    if self[:notation].blank? == ( self[:from_coord].blank? && self[:to_coord].blank? )
      raise 'Please only attempt to specify a notation, or a from/to coordinate pair.' 
    end
  end

  def analyze_board_position
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
      errors.add :notation, "Failed to infer move coordinates from #{notation}" and return 
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

  def infer_coordinates_from_notation
    
    #expand the castling notation
    if self[:notation].include?('O-O')
      new_notation = 'K' + (self[:notation].include?('O-O-O') ? 'c' : 'g')
      new_notation += (match.next_to_move == :white) ? '1' : '8'
      self[:notation] = new_notation
    end
    
    self[:to_coord] =  notation.to_s[-2,2]
    role = NOTATION_TO_ROLE_MAP[ notation[0,1] ] ? NOTATION_TO_ROLE_MAP[ notation[0,1] ] : 'pawn'

    @possible_movers = @board.select do |pos, piece| 
      piece.side == match.next_to_move && 
      piece.role == role && 
      piece.allowed_moves(@board, pos).include?( self[:to_coord] )
    end

    self[:from_coord] = @possible_movers[0][0] if @possible_movers.length == 1
  end

  #returns the notation for a given move - depends on alot of things - whether check was given, a capture made, etc..
  def notate
    # allow calling outside of activerecord lifecycle
    analyze_board_position unless @board

    # start off with the pieces own notation
    mynotation = @piece_moving.notation( from_coord[0].chr )
    
    # disambiguate which piece moved if a 'sister_piece' could have moved there as well
    if( @piece_moving.role=='rook') || (@piece_moving.role=='knight')
      mynotation = mynotation[0].chr

      # look for a piece of the same type which also could have moved 
      sister_piece_pos, sister_piece = @board.consider_move(self) do |b|
          b.sister_piece_of(@piece_moving, from_coord)
      end

      if( sister_piece != nil && sister_piece.allowed_moves(@board, sister_piece_pos).include?(to_coord) )
        #prefer using file to disambiguate but use rank if file insufficient
        # mynotation += ( @piece_moving.file != sister_piece.file) ? @piece_moving.file : @piece_moving.rank
        mynotation += ( from_coord[0] != sister_piece_pos[0]) ? from_coord[0].chr : from_coord[1].chr
      end
    end
        
    if @piece_moved_upon && (@piece_moving.side != @piece_moved_upon.side) || @board.is_en_passant_capture?( from_coord, to_coord )
      mynotation += 'x' 
      captured = true
    end

    #notate the destination square - a straight append except for noncapturing pawns
    mynotation = '' if( (@piece_moving.role=='pawn') && !captured )
    mynotation += to_coord
        
    #castling 3 O's if queenside otherwise 2 O's
    if castled == 1
      mynotation = 'O-O' + ((to_coord[0].chr=='c') ? '-O' : '' ) 
    end

    #promotion
    if @piece_moving.promotable?( to_coord[1].chr )
      mynotation += "=#{promotion_choice}"
    end
    
    #check/mate
    mynotation += '+' if @board.consider_move(self) do |b|
      b.in_check?( @piece_moving.side==:white ? :black : :white )
    end

    return mynotation
  end
  
end
