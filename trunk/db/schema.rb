# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20080729005133) do

  create_table "matches", :force => true do |t|
    t.integer  "player1_id",  :limit => 11,                    :null => false
    t.integer  "player2_id",  :limit => 11,                    :null => false
    t.boolean  "active",                    :default => true
    t.boolean  "moves_count",               :default => false
    t.integer  "winner_id",   :limit => 11
    t.string   "outcome"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "moves", :force => true do |t|
    t.integer  "match_id",        :limit => 11
    t.integer  "move_number",     :limit => 11
    t.string   "from_coord",      :limit => 2,  :null => false
    t.string   "to_coord",        :limit => 2,  :null => false
    t.string   "capture_coord",   :limit => 2
    t.string   "notation",        :limit => 7
    t.boolean  "castled"
    t.string   "promotion_piece", :limit => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "players", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

end
