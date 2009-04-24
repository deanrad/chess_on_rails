class CreateChats < ActiveRecord::Migration
  def self.up
    create_table :chats do |t|
      t.integer :match_id, :null => false
      t.integer :player_id, :null => false
      t.string :text
      t.datetime :created_at

      t.timestamps
    end
  end

  def self.down
    drop_table :chats
  end
end
