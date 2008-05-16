class CreateFacebookUsers < ActiveRecord::Migration
  def self.up
	  create_table :facebook_users do |t|
		  t.column :fb_user_id, :integer
		  t.column :playing_as, :int
		  t.timestamps
	  end
	  execute("alter table facebook_users modify fb_user_id bigint")
  end

  def self.down
	drop_table :facebook_users
  end
end
