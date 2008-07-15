class Move < ActiveRecord::Base
	belongs_to :match

	attr_accessor :side
	before_validation :analyze_board_position
	before_save :update_computed_fields
	after_save  :handle_checkmate

	NOTATION_TO_ROLE_MAP = { 'R' => 'rook', 'N' => 'knight', 'B' => 'bishop', 'Q' => 'queen', 'K' => 'king' }

	def analyze_board_position
		@board = match.board

		#determine coordinates from notation
		infer_coordinates_from_notation if !self[:notation].blank? && (from_coord.blank? || to_coord.blank?)

		@piece_moving = @board.piece_at(from_coord)
		@piece_moved_upon = @board.piece_at(to_coord)
	end

	#fields like the notation and whether this was a castling are stored with the move
	def update_computed_fields
		#enpassant
		if @board.is_en_passant_capture?( from_coord, to_coord )
			self[:captured_piece_coord] = to_coord.gsub( /3/, '4' ).gsub( /6/, '5' )
		end

		#promotion
		where_p_will_be = @piece_moving.clone
		where_p_will_be.position = to_coord
		self[:promotion_choice] ||= 'Q' if where_p_will_be.promotable?

		#castling
		self[:castled] = 1 if (@piece_moving.type==:king && from_coord[0].chr=='e' && ['c','g'].include?( to_coord[0].chr ) )

		#finally ensure move is notated
		self[:notation] ||= notate
	end

	#stuff here depends on knowledge of the board's position prior to the move being committed
	# this should be considered a before-save function and maybe validate is not exactly the best place
	def validate

		if self[:notation].blank? && ( self[:from_coord].blank? || self[:to_coord].blank? )
			errors.add_to_base 'Please only attempt to specify a notation, or a from/to coordinate pair.' 
		end

		#ensure the validity of the coordinates we have whether specified or inferred
		[from_coord, to_coord].each do |coord|
			errors.add_to_base "#{coord} is not a valid coordinate" unless Chess.valid_position?( coord )
		end

		#verify allowability of the move
		
		errors.add_to_base "No piece present at #{from_coord} on this board" and return if !@piece_moving
		errors.add_to_base "#{@piece_moving.role} not allowed to move to #{to_coord}" unless @piece_moving.allowed_moves(@board).include?( to_coord ) 
		
	end

	def infer_coordinates_from_notation
		self[:to_coord] =  notation.to_s[-2,2]
		role = NOTATION_TO_ROLE_MAP[ notation[0,1] ] ? NOTATION_TO_ROLE_MAP[ notation[0,1] ] : 'pawn'

		possible_movers = @board.pieces.select{ |p| p.side == match.next_to_move && p.role == role && p.allowed_moves(@board).include?( self[:to_coord] ) }
		raise ArgumentError, "No #{side} piece capable of moving to #{self[:to_coord]} on this board" if possible_movers.length==0
		raise ArgumentError, "Ambiguous move #{notation}." if possible_movers.length>1

		self[:from_coord] = possible_movers[0].position
	end

	#returns the notation for a given move - depends on alot of things - whether check was given, a capture made, etc..
	def notate
		# allow calling outside of activerecord lifecycle
		analyze_board_position unless @board

		# start off with the pieces own notation
		mynotation = @piece_moving.notation
		
		# disambiguate which piece moved if a 'sister_piece' could have moved there as well
		if( @piece_moving.role=='rook') || (@piece_moving.role=='knight')
			mynotation = mynotation[0].chr
			sister_piece = @board.sister_piece_of(@piece_moving)
			if( sister_piece != nil && sister_piece.allowed_moves(@board).include?(to_coord) )
				#prefer using file to disambiguate but use rank if file insufficient
				mynotation += ( @piece_moving.file != sister_piece.file) ? @piece_moving.file : @piece_moving.rank
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

		#relocate the piece now and notate a few more things
		@piece_moving.position = to_coord

		#promotion
		if @piece_moving.promotable?
			mynotation += promotion_choice
		end
		
		#check/mate
		mynotation += '+' if @board.in_check?(  @piece_moving.side==:white ? :black : :white  )

		return mynotation
	end

	def handle_checkmate
		#if they got the other guy on this move 
		#todo - more model-esque - possibly decommissioning this controller and working just with match
		this_guy = @match.next_to_move
		if @match.reload.board.in_checkmate?( this_guy )
			@match.checkmate_by( this_guy == :black ? :white : :black  )
		end
				
	end
end