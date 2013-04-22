class Player < ActiveRecord::Base
  attr_accessible :active, :id, :name
  has_many :gameplays
  has_many :matches, through: :gameplays
end
