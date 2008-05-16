module MatchHelper
	#(todo - dynamicize the match url below)
	def fb_url( relative_part )
		"http://enpassant.dyndns.org:3000/match/6/#{relative_part}"
	end
end
