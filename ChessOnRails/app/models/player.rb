class Player < ActiveRecord::Base
	
	validates_length_of :name, :maximum=>20
	validates_uniqueness_of :name

	belongs_to :user

	#note the single quotes below ! we don't want id substituted too soon
	#ref: http://railsblaster.wordpress.com/2007/08/27/has_many-finder_sql/
	has_many :active_matches, :class_name=>"Match",
		:finder_sql=>'SELECT matches.*
					    FROM matches
						WHERE ( player1 = #{id} OR player2= #{id} )
						AND active=1'
	
    has_many  :matches, :class_name=>"Match",

		:finder_sql=>'SELECT matches.*
					    FROM matches
						WHERE ( player1 = #{id} OR player2= #{id} )'

    # named so as not to conflict with AR current_match, referenced below
    # TODO can override with same name and call base.current_match within
    def my_current_match
        Match.find( current_match )
    end


    def match(id=nil)
       return my_current_match if !id
       return Match.find(id)
    end


end
