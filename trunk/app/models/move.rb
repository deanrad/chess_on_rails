class Move < ActiveRecord::Base
	belongs_to :match

	attr_accessor :side

	NOTATION_TO_ROLE_MAP = { 'R' => 'rook', 'N' => 'knight', 'B' => 'bishop', 'Q' => 'queen', 'K' => 'king' }

	#stuff here depends on knowledge of the board's position prior to the move being committed
	# this should be considered a before-save function and maybe validate is not exactly the best place
	def validate
		errors.add(:match, 'You have not specified which match.') and raise ArgumentError, 'No match' if ! match
		errors.add(:active, 'You cannot make a move for an inactive match, silly !') if match.active != 1

		side = match.next_to_move

		if( notation && (!from_coord || !to_coord || from_coord.empty? || to_coord.empty? ))
			self[:to_coord] =  notation.to_s[-2,2]

			role = NOTATION_TO_ROLE_MAP[ notation[0,1] ] ? NOTATION_TO_ROLE_MAP[ notation[0,1] ] : 'pawn'

			p = match.board.pieces.find{ |p| p.side == side && p.role == role && p.allowed_moves(match.board).include?( self[:to_coord] ) }
			raise ArgumentError, "No #{side} piece capable of moving to #{self[:to_coord]} on this board or ambiguous move #{notation}" if !p 

			self[:from_coord] = p.position
		end

		[from_coord, to_coord].each do |coord|
			raise ArgumentError, "#{coord} is not a valid coordinate" if ! Chess.valid_position?( coord )
		end

		p = match.board.pieces.find{ |p| (p.position == from_coord) && p.allowed_moves(match.board).include?( to_coord ) }
		raise ArgumentError, "No #{side} piece capable of moving to #{self[:to_coord]} on this board or ambiguous move #{notation}" if !p 

		if match.board.is_en_passant_capture?( from_coord, to_coord )
			self[:captured_piece_coord] = to_coord.gsub( /3/, '4' ).gsub( /6/, '5' )
		end

		self[:notation] = notate if !@notation
		self[:castled] = self[:notation].include?( 'O-' )

	end

	def notate
		

		this_board = match.board
		#raise ArgumentError, "Got here: from_coord is #{from_coord}, board is #{this_board}"

		piece_moving = this_board.piece_at( from_coord )

		#raise ArgumentError, "No piece present on coordinate #{from_coord} in match #{match.id}" if ! piece_moving
		
		# start off with the pieces own notation
		mynotation = piece_moving.notation
		
		# disambiguate which piece moved if a 'sister_piece' could have moved there as well
		if( piece_moving.role=='rook') || (piece_moving.role=='knight')
			mynotation = mynotation[0].chr
			sister_piece = this_board.sister_piece_of(piece_moving)
			if( sister_piece != nil && sister_piece.allowed_moves(this_board).include?(to_coord) )
				#prefer using file to disambiguate but use rank if file insufficient
				mynotation += ( piece_moving.file != sister_piece.file) ? piece_moving.file : piece_moving.rank
			end
		end
		
		piece_moved_upon  = match.board(:current).piece_at( to_coord )
		
		if piece_moved_upon && (piece_moving.side != piece_moved_upon.side) || this_board.is_en_passant_capture?( from_coord, to_coord )
			mynotation += 'x' 
			captured = true
		end

		#destination square
		if( (piece_moving.role=='pawn') && !captured )
			mynotation += to_coord[1].chr
		else
			mynotation += to_coord
		end
		
		#castling
		if ( piece_moving.role=='king' && from_coord[0].chr=='e')
			if(  to_coord[0].chr=='g')
				mynotation='O-O'
			elsif( to_coord[0].chr=='c' )
				mynotation='O-O-O'
			end
		end
		
		piece_moving.position = to_coord
		mynotation += '+' if this_board.in_check?(  piece_moving.side==:white ? :black : :white  )
		piece_moving.position = from_coord #move back
		
		return mynotation
	end
end