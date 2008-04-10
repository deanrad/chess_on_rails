
#An instance of a piece bound to a particular match
# (Currently not aware of matches in any tests)
class Piece  # < ActiveRecord::Base

	require 'Enumerable'
		
	#the allowed types for the type instance accessor (and their shorthand)
	#todo: remove pawn
	@@types = {:kings_rook =>'R#{file}', :kings_knight =>'N#{file}',  :kings_bishop=>'B',  
		:queens_rook=>'R#{file}', :queens_knight=>'N#{file}',  :queens_bishop=>'B', 
		:king=>'K',  :queen=>'Q',
		:a_pawn=>'a', :b_pawn=>'b', :c_pawn=>'c', :d_pawn=>'d',
		:e_pawn=>'e', :f_pawn=>'f', :g_pawn=>'g', :h_pawn=>'h'
	}
	
	#the allowed sides for the side instance accessor (and their shorthand)
	@@sides = {:white=>"W", :black=>"B"}
	
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
		
		if pos
			@position=pos
		end
		
        #if !valid?
		#	raise ArgumentError, "Invalid side:#{side} or type:#{type} in piece creation"
		#end
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
		#%Q{"#{f}"}
		type_text = @@types[@type]
		return eval( %Q{ "#{type_text}" } )
	end
	
	#eliminates theoretical moves that would not be applicable on a certain board
	# for reasons of: 1) would be on your own sides square
	# 2) would place your king in check
	def allowed_moves(board)
		theoretical_moves
	end
	
	#the moves a piece could move to on an empty board
	def theoretical_moves
		raise ArgumentError, "Cannot determine theoretical moves of piece #{self.to_s} if position unspecified" if ! position
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
			@moves << (file[0] + (file_unit) ).chr + (rank.to_i + (rank_unit)).to_s
		end
	end
	
	def calc_theoretical_moves_queen
		
		@lines_of_attack = [1,0,-1].cartesian( [1,0,-1] ).reject! { |x| x==[0,0] }
		@lines_of_attack.each do |file_unit, rank_unit|
			(1..8).each do |length|
				@moves << (file[0] + (file_unit*length) ).chr + (rank.to_i + (rank_unit*length)).to_s
			end
		end
	end
	
	def calc_theoretical_moves_rook
		
		@lines_of_attack = [ [1,0], [-1,0], [0,1], [0,-1] ]
		@lines_of_attack.each do |file_unit, rank_unit|
			(1..8).each do |length|
				@moves << (file[0] + (file_unit*length) ).chr + (rank.to_i + (rank_unit*length)).to_s
			end
		end
	end
	
	def calc_theoretical_moves_bishop
		
		@lines_of_attack = [ [1,1], [-1,1], [1,-1], [-1,-1] ]
		@lines_of_attack.each do |file_unit, rank_unit|
			(1..8).each do |length|
				@moves << (file[0] + (file_unit*length) ).chr + (rank.to_i + (rank_unit*length)).to_s
			end
		end
	end
	

	# a knight has no lines of attack	
	def calc_theoretical_moves_knight
		
		[ [1,2], [1,-2], [-1,2], [-1,-2], [2,1], [2,-1], [-2,1], [-2,-1] ].each do | file_unit, rank_unit |
			@moves << (file[0] + (file_unit) ).chr + (rank.to_i + (rank_unit)).to_s
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

#	def validate
		
		#errors.add(:side, "I dont like that side " + @side.to_s)
		
		#if ! @@types.has_key? @type
		#	errors.add(:type, "Unknown type " + @type.to_s + ". It may help to specify :queens_bishop instead of :bishop for example ")
		#end
		#
		#if ! @@sides.has_key? @side
		#	errors.add(:side, "Unknown side " + @side.to_s + ". Valid sides are :black and :white")
		#end
		
		#must be a known type
		#if !@@types.includes?(@type) 
		#	errors.add(:type, "Unknown type [${@type}]")
		#end

#	end
end
