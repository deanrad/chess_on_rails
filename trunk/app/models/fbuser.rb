class Fbuser < ActiveRecord::Base
  belongs_to :playing_as,  :class_name => 'Player', :foreign_key => 'playing_as'

  def name= ( name )
    playing_as.name = name
    playing_as.save!
  end
  def name
    playing_as.name
  end
end
