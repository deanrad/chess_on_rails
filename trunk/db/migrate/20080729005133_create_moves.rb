class CreateMoves < ActiveRecord::Migration
  def self.up
    create_table :moves do |t|
      t.integer :match_id
      t.integer :move_number
      t.string  :from_coord,      :limit => 2, :null => false
      t.string  :to_coord,        :limit => 2, :null => false
      t.string  :capture_coord,   :limit => 2
      t.string  :notation,        :limit => 7
      t.boolean :castled
      t.string  :promotion_piece, :limit => 1

      t.timestamps
    end
  end

  def self.down
    drop_table :moves
  end
end
