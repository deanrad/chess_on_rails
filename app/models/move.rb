class Move
  include Mongoid::Document
  field :from
  field :to
  field :notation
    
  embedded_in :match, :inverse_of => :moves
end