class MatchEndingFields < ActiveRecord::Migration
  def self.up
	add_column :matches, :result, :text, :limit => 10
	add_column :matches, :win_claimed_by, :int
	add_column :matches, :winning_player, :int
  end

  def self.down
	remove_column :matches, :result
	remove_column :matches, :win_claimed_by
	remove_column :matches, :winning_player
  end
end
