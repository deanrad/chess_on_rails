class UserPreferences < ActiveRecord::Migration
  def self.up
    change_table(:users) do |t|
      t.boolean :preferences_email_on_new_match, :default => true
      t.boolean :preferences_email_on_new_move, :default => true
      t.integer :preferences_email_on_new_move_window, :default => 60
    end
  end

  def self.down
    change_table(:users) do |t|
      t.remove :preferences_email_on_new_match, :preferences_email_on_new_move, 
        :preferences_email_on_new_move_window
    end
  end
end
