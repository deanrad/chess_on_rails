class Player
  include Mongoid::Document
  field :name, :type => String
  field :active, :type => Boolean
  
  has_many :white_matches, :class_name => 'Match', :inverse_of => :white
  has_many :black_matches, :class_name => 'Match', :inverse_of => :black

end