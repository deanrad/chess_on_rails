# While it'd be more proper to have this on the players table, or linked to from there,
# Clearance editing pages will give quick/dirty access to these preferences if they're 
# on the users model/table, which is the one clearance serves up currently...
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
