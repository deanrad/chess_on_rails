class CreateMatches < ActiveRecord::Migration
  def self.up
    create_table :matches do |t|
      t.integer :player1_id,  :null => false
      t.integer :player2_id,  :null => false
      t.boolean :active,      :default => true
      t.string  :name, :limit => 25
      t.integer :winner_id
      t.string  :outcome

      t.timestamps
    end
  end

  def self.down
    drop_table :matches
  end
end
