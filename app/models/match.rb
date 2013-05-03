class Match
  include Mongoid::Document

  field :name
  field :active, :type => Boolean

  belongs_to :white, class_name: "Player", inverse_of: "white_matches"
  belongs_to :black, class_name: "Player", inverse_of: "black_matches"
  
  embeds_many :moves

end