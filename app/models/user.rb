class User < ActiveRecord::Base
    belongs_to :playing_as, :class_name=>"Player", :foreign_key=>"playing_as"
    
    
end
