module Enumerable
	def cartesian(other)
		res = []
		each { |x| other.each{ |y| res << [x,y] }  } 
		return res
	end
end