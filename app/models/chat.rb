class Chat < ActiveRecord::Base
  belongs_to :match
  belongs_to :player
end
