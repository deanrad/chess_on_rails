module Notation; end # unconfuse rails' easily confused loader 

module MoveNotation

  NOTATION_TO_FUNCTION_MAP = { 'R' => :rook, 'N' => :knight, 'B' => :bishop, 'Q' => :queen, 'K' => :king }

  # available to move model, sets fields on self based on self[:notation]
  def infer_coordinates_from_notation

    # handle a1b1 style moves - common style, but not part of the SAN grammar
    if notation =~ /[a-h][1-8][a-h][1-8]/
      self.from_coord = notation[0..1]
      self.to_coord = notation[2..3]
      return 
    end

    #expand the castling notation
    if notation.include?('O-O')
      new_notation = 'K' + (self[:notation].include?('O-O-O') ? 'c' : 'g')
      new_notation += (match.side_to_move == :white) ? '1' : '8'
      self.notation = new_notation
    end

    self.to_coord =  notation[-2,2]
    function = NOTATION_TO_FUNCTION_MAP[ notation[0,1] ] || :pawn
    @possible_movers = board.select do |pos, piece| 
      piece.side == match.side_to_move && 
      piece.function == function && 
      piece.allowed_moves(board).include?( to_coord_sym )
    end

    self.from_coord = @possible_movers[0][0].to_s and return if @possible_movers.length == 1
    disambiguator = notation[-3,1]
    matcher = (disambiguator =~ /[1-8]/) ? Regexp.new( "^.#{disambiguator}$" ) : Regexp.new( "^#{disambiguator}.$" )
    movers = @possible_movers.select { |pos, piece| matcher.match(pos.to_s) }

    self.from_coord = movers[0][0].to_s and return if movers.length == 1

  end

  # Returns the notation for a given move - depends on alot of things - whether check was given, a capture made, etc..
  # - Prefer using file to disambiguate but use rank if file insufficient
  # - Most pieces have their piecetype abbreviation ( N for knight ), pawns have their file
  def notate
    # allow calling outside of activerecord lifecycle
    analyze_board_position unless @board

    mynotation = @piece_moving.abbrev.upcase.sub('P', from_coord_sym.file)
    
    # disambiguate which piece moved if a 'sister_piece' could have moved there as well
    if( @piece_moving.function==:rook) || (@piece_moving.function==:knight)

      # look for a piece of the same type which also could have moved 
      sister_piece_pos, sister_piece = @board.consider_move(self) do |b|
        b.sister_piece_of(@piece_moving, from_coord)
      end

      if( sister_piece != nil && sister_piece.allowed_moves(@board).include?(to_coord_sym) )
        mynotation += ( from_coord_sym.file != sister_piece_pos.file) ? from_coord_sym.file : from_coord_sym.rank.to_s
      end
    end
        
    if @piece_moved_upon && (@piece_moving.side != @piece_moved_upon.side) || captured_piece_coord
      mynotation += 'x' 
      captured = true
    end

    #notate the destination square - a straight append except for noncapturing pawns
    mynotation = '' if( (@piece_moving.function==:pawn) && !captured )
    mynotation += to_coord
        
    #castling 3 O's if queenside otherwise 2 O's
    if castled == 1
      mynotation = 'O-O' + ((to_coord_sym.file=='c') ? '-O' : '' ) 
    end

    #promotion
    if @piece_moving.function == :pawn && to_coord_sym.rank == @piece_moving.promotion_rank
      mynotation += "=#{promotion_choice || 'Q'}"
    end
    
    #check/mate
    mynotation += '+' if @board.consider_move(self) do |b|
      b.in_check?( @piece_moving.side==:white ? :black : :white )
    end

    return mynotation
  end

end
