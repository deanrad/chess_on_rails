class User < ActiveRecord::Base
  include Clearance::User
  belongs_to :playing_as, :class_name => "Player", :foreign_key => "playing_as"

  def admin?; !! self.admin; end

end
