# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 4) do

  create_table "matches", :force => true do |t|
    t.integer  "player1",                   :null => false
    t.integer  "player2",                   :null => false
    t.integer  "active",     :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "moves", :force => true do |t|
    t.integer  "match_id"
    t.integer  "moved_by"
    t.string   "from_coord",           :limit => 10
    t.string   "to_coord",             :limit => 10
    t.string   "notation",             :limit => 10
    t.integer  "castled",                            :default => 0
    t.string   "captured_piece_coord", :limit => 10
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "players", :force => true do |t|
    t.string  "name",          :limit => 20
    t.integer "current_match"
  end

  add_index "players", ["name"], :name => "index_players_on_name", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email",                :limit => 50
    t.integer  "playing_as"
    t.string   "security_phrase",      :limit => 200
    t.string   "security_phrase_hint", :limit => 200
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
