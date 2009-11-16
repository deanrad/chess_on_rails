class CreateChats < ActiveRecord::Migration
  def self.up
    create_table :chats do |t|
      t.integer :match_id, :null => false
      t.integer :player_id, :null => false
      t.string :text

      # these fields extend chat so it can be used to convey actions like draw offers
      t.integer :action_code
      t.integer :responding_to_chat_id
      t.integer :response_code

      t.timestamps
    end
  end

  def self.down
    drop_table :chats
  end
end
