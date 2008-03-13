class Player < ActiveRecord::Base
	
	# although Player has the following properties, to declare them explicitly would be
	# to override the active record functionality which we don't want to do !
	
	#attr_accessor :name
	#attr_accessor :win_loss
	
end
