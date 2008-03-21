class Player < ActiveRecord::Base
	
	belongs_to :user
	#note the single quotes below ! we don't want id substituted too soon
	#ref: http://railsblaster.wordpress.com/2007/08/27/has_many-finder_sql/
	has_many :active_matches, :class_name=>"Match",
		:finder_sql=>'SELECT matches.*
					    FROM matches
						WHERE ( player1 = #{id} OR player2= #{id} )
						AND active=1'
	
	has_many :matches, :class_name=>"Match",
		:finder_sql=>'SELECT matches.*
					    FROM matches
						WHERE ( player1 = #{id} OR player2= #{id} )'
	
	validates_length_of :name, :maximum=>20
	validates_uniqueness_of :name
	
	# although Player has the following properties, to declare them explicitly would be
	# to override the active record functionality which we don't want to do !
	
	#attr_accessor :name
	#attr_accessor :win_loss
	
end
