#An instance of a piece bound to a particular match
# (Currently not aware of matches in any tests)
class Piece < ActiveRecord::Base
	
	#the allowed types for the type instance accessor (and their shorthand)
	@@types = {:kings_rook =>'R#{@file}', :kings_knight =>'N#{@file}',  :kings_bishop=>'B',  
		:queens_rook=>'R#{@file}', :queens_knight=>'N#{@file}',  :queens_bishop=>'B', 
		:king=>'K',  :queen=>'Q',  :pawn=>'#{@file}'}
	
	#the allowed sides for the side instance accessor (and their shorthand)
	@@sides = {:white=>"W", :black=>"B"}
	
	attr_accessor :type
	attr_accessor :side
	
	attr_accessor :file
	attr_accessor :rank
	
	attr_accessor :match_id, :int
	
	def advance_direction
		return 1 if @side == :white
		return -1 if @side == :black
	end
	
	def position
		@file+@rank
	end
	
	#the moves a piece could move to on an empty board
	def theoretical_moves
		return @moves if @moves != nil 
		
		@moves = []

		if @type == :pawn
			calc_theoretical_moves_pawn
		elsif @type == :queens_knight || @type == :kings_knight
			calc_theoretical_moves_knight
		end
		
		@moves.reject! { |pos| ! Chess.valid_position?( pos ) }
		return @moves
	end
	
	def calc_theoretical_moves_knight
		directions = [1, -1]
		units = [1,2]
		
		[ [1,2], [1,-2], [-1,2], [-1,-2], [2,1], [2,-1], [-2,1], [-2,-1] ].each do | file_unit, rank_unit |
			@moves << (@file[0] + (file_unit) ).chr + (@rank.to_i + (rank_unit)).to_s
		end
	end
	
	def calc_theoretical_moves_pawn
		
		[ [:white,'2'], [:black,'7'] ].each do |side, front_rank|
			if @side == side
				
				#the single advance, and double from home rank
				@moves << @file.to_s + (@rank.to_i + advance_direction).to_s
				
				if @rank==front_rank
					@moves << @file.to_s + (@rank.to_i + 2 * advance_direction).to_s
				end
				
				#the diagonal captures
				@moves << (@file[0].to_i - 1).chr + (@rank.to_i + advance_direction).to_s
				@moves << (@file[0].to_i + 1).chr + (@rank.to_i + advance_direction).to_s
			end
			
		end
	end
	
	#The part of the notation - with a piece disambiguator for pawns minors and rooks
	# It will be removed later if deemed unnecessary
	def notation
		#%Q{"#{f}"}
		type_text = @@types[@type]
		return eval( %Q{ "#{type_text}" } )
	end
	
	def initialize(side, type)
		@side = side
		@type = type
	end
	
	def validate
		
		#errors.add(:side, "I dont like that side " + @side.to_s)
		
		if ! @@types.has_key? @type
			errors.add(:type, "Unknown type " + @type.to_s + ". It may help to specify :queens_bishop instead of :bishop for example ")
		end
		
		if ! @@sides.has_key? @side
			errors.add(:side, "Unknown side " + @side.to_s + ". Valid sides are :black and :white")
		end
		
		#must be a known type
		#if !@@types.includes?(@type) 
		#	errors.add(:type, "Unknown type [${@type}]")
		#end
	end
end
