
#An instance of a piece bound to a particular match
# (Currently not aware of matches in any tests)
class Piece  
	require 'Enumerable'

	#the allowed types for the type instance accessor (and their shorthand)
	@@types = {:kings_rook =>'R', :kings_knight =>'N',  :kings_bishop=>'B',  
		:queens_rook=>'R', :queens_knight=>'N',  :queens_bishop=>'B', 
		:king=>'K',  :queen=>'Q',
		:a_pawn=>'a', :b_pawn=>'b', :c_pawn=>'c', :d_pawn=>'d',
		:e_pawn=>'e', :f_pawn=>'f', :g_pawn=>'g', :h_pawn=>'h'
	}
	
	#the allowed sides for the side instance accessor (and their shorthand)
	#@@sides = {:white=>"W", :black=>"B"}
	
	def self.types
		return @@types.keys
	end
	
	attr_accessor :type
	attr_accessor :side
	attr_accessor :position
	
	attr_accessor :match_id, :int
	
	def initialize(side, type, pos=nil)
		@side = side
		@type = type
		@position = pos
	end
	
	#when rendered the client id uniquely specifies an individual piece within a board
	#example: white_f_pawn
	def client_id
		"#{@side}_#{@type}"
	end
	
	def file
		return @position[0].chr
	end
	def rank
		return @position[1].chr
	end
	
	def to_s
		return "Side: #{@side} type:#{@type} at #{position}"
	end
	
	def piece_type
		if @type.to_s.include?('_')
			return @type.to_s.split('_')[1];
		else
			return @type.to_s
		end
	end
	
	def advance_direction
		return 1 if @side == :white
		return -1 if @side == :black
	end
	
	#bishops and rooks (and the queen) have 'lines of attack', or directions which can be stopped by ones own piece
	def lines_of_attack
		return [] if ! @lines_of_attack
		
		@lines_of_attack
	end
	
	#The part of the notation - with a piece disambiguator for pawns minors and rooks
	# It will be removed later if deemed unnecessary
	def notation
		return @@types[@type] if piece_type != 'pawn'
		return file
		#return eval( %Q{ "#{type_text}" } )
	end
	
	#eliminates theoretical moves that would not be applicable on a certain board
	# for reasons of: 1) would be on your own sides square
	# 2) would place your king in check
	def allowed_moves(board)
		m = []
		tm = theoretical_moves # fetch these, only return if needed
		
		#bishops queens and rooks have 'lines of attack' rules
		if lines_of_attack.length > 0 
			lines_of_attack.each do |line_of_attack|
				# if a line of attack is blocked, remove it from the list
				line_worth_following = true
				
				file_unit, rank_unit = line_of_attack
				
				(1..8).each do |length|
					
					pos = (file[0] + (file_unit*length) ).chr + (rank.to_i + (rank_unit*length)).to_s
					next unless line_worth_following
					next unless Chess.valid_position?( pos ) 

					if( @side == board.side_occupying(pos) )
						# ran into your own piece- disregard this line
						line_worth_following = false
					elsif ( board.side_occupying(pos) == nil )
						m << pos
					else
						#ran into opponents piece -this is the last position you can occupy on this line
						m << pos
						line_worth_following = false
					end
				end
				
			end
		else
			#knights pawns and kings
			
			#start by excluding squares you occupy 
			m = tm.reject { |pos| @side == board.side_occupying(pos) }
			
			#for pawns 
			if( @type.to_s.include?(:pawn.to_s) )

				# exclude non-forward moves unless captures or en_passant (6th and 3rd rank captures behind doubly advanced pawn)
				m.reject! do |pos| 
					#diagonals are excluded if empty (unless en passant)
					if (pos[0] != @position[0]) 
						(board.side_occupying(pos) == nil) && ! board.is_en_passant_capture?( @position, pos )
					else
					#exclude the straight move if square occupied
						board.side_occupying(pos) != nil 
					end
				end
				
				# exclude forward moves if blocked 
				#m.reject! { |pos| (pos[0] == @position[0]) && ( board.side_occupying(pos) != nil ) }
			end

			if( piece_type=="king")
				#castling
				castle_rank = (side==:white) ? "1" : "8"
				
				#not accounting for previous moves, yes, or castling across check, but this to be remedied with test coverage
				king_on_initial_square = (position == ("e"+castle_rank) )
				kings_rook_on_initial_square = (board.piece_at( "h"+castle_rank) != nil) && (board.piece_at( "h"+castle_rank).piece_type=="rook")
				intervening_kingside_squares_empty = (board.piece_at( "g"+castle_rank) == nil) && (board.piece_at( "f"+castle_rank) == nil)
				
				if(king_on_initial_square && kings_rook_on_initial_square && intervening_kingside_squares_empty  )
					m << "g"+castle_rank
				end
				
				queens_rook_on_initial_square = (board.piece_at( "a"+castle_rank) != nil) && (board.piece_at( "a"+castle_rank).piece_type=="rook")
				intervening_queenside_squares_empty = (board.piece_at( "d"+castle_rank) == nil) && (board.piece_at( "c"+castle_rank) == nil) && (board.piece_at( "b"+castle_rank) == nil)

				if(king_on_initial_square && queens_rook_on_initial_square && intervening_queenside_squares_empty  )
					m << "c"+castle_rank
				end

			end
		end
		
		return m
	end
	
	#the moves a piece could move to on an empty board
	def theoretical_moves
		#raise ArgumentError, "Cannot determine theoretical moves of piece #{self.to_s} if position unspecified" if ! position
		@moves = []
		
		if @type.to_s.include?(:pawn.to_s)
			calc_theoretical_moves_pawn
		elsif @type == :queen
			calc_theoretical_moves_queen
		elsif @type == :king
			calc_theoretical_moves_king
		elsif @type == :queens_knight || @type == :kings_knight
			calc_theoretical_moves_knight
		elsif @type == :queens_rook || @type == :kings_rook
			calc_theoretical_moves_rook
		elsif @type == :queens_bishop || @type == :kings_bishop
			calc_theoretical_moves_bishop
		end
		
		#puts "\nLines of attack for piece #{self.to_s}:\t" + (self.lines_of_attack.join(','))

		@moves.reject! { |pos| ! Chess.valid_position?( pos ) }
		return @moves
	end
		
	def calc_theoretical_moves_king
		
		lines_of_attack = [1,0,-1].cartesian( [1,0,-1] ).reject! { |x| x==[0,0] }
		lines_of_attack.each do |file_unit, rank_unit|
			pos = (file[0] + (file_unit) ).chr + (rank.to_i + (rank_unit)).to_s
			@moves << pos if Chess.valid_position?( pos )
		end
	end
	
	def calc_theoretical_moves_queen
		
		@lines_of_attack = [1,0,-1].cartesian( [1,0,-1] ).reject! { |x| x==[0,0] }
		@lines_of_attack.each do |file_unit, rank_unit|
			(1..8).each do |length|
				pos = (file[0] + (file_unit*length) ).chr + (rank.to_i + (rank_unit*length)).to_s
				@moves << pos if Chess.valid_position?( pos )
			end
		end
	end
	
	def calc_theoretical_moves_rook
		
		@lines_of_attack = [ [1,0], [-1,0], [0,1], [0,-1] ]
		@lines_of_attack.each do |file_unit, rank_unit|
			(1..8).each do |length|
				pos = (file[0] + (file_unit*length) ).chr + (rank.to_i + (rank_unit*length)).to_s
				@moves << pos if Chess.valid_position?( pos )
			end
		end
	end
	
	def calc_theoretical_moves_bishop
		
		@lines_of_attack = [ [1,1], [-1,1], [1,-1], [-1,-1] ]
		@lines_of_attack.each do |file_unit, rank_unit|
			(1..8).each do |length|
				pos = (file[0] + (file_unit*length) ).chr + (rank.to_i + (rank_unit*length)).to_s
				@moves << pos if Chess.valid_position?( pos )
			end
		end
	end
	

	# a knight has no lines of attack	
	def calc_theoretical_moves_knight
		
		[ [1,2], [1,-2], [-1,2], [-1,-2], [2,1], [2,-1], [-2,1], [-2,-1] ].each do | file_unit, rank_unit |
			pos = (file[0] + (file_unit) ).chr + (rank.to_i + (rank_unit)).to_s
			@moves << pos if Chess.valid_position?( pos )
		end
	end
	
	def calc_theoretical_moves_pawn
		
		[ [:white,'2'], [:black,'7'] ].each do |side, front_rank|
			if @side == side
				
				#the single advance, and double from home rank
				@moves << file.to_s + (rank.to_i + advance_direction).to_s
				
				if rank==front_rank
					@moves << file.to_s + (rank.to_i + 2 * advance_direction).to_s
				end
				
				#the diagonal captures
				@moves << (file[0].to_i - 1).chr + (rank.to_i + advance_direction).to_s
				@moves << (file[0].to_i + 1).chr + (rank.to_i + advance_direction).to_s
			end
			
		end
	end

	def img_name
		( (type.to_s.split('_').length==2) ? type.to_s.split('_')[1] : type.to_s) + '_' + side.to_s.slice(0,1)
	end

end
