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

ActiveRecord::Schema.define(:version => 20091112043949) do

  create_table "chats", :force => true do |t|
    t.integer  "match_id",              :null => false
    t.integer  "player_id",             :null => false
    t.string   "text"
    t.integer  "action_code"
    t.integer  "responding_to_chat_id"
    t.integer  "response_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gameplays", :force => true do |t|
    t.integer  "player_id",                                   :null => false
    t.integer  "match_id",                                    :null => false
    t.boolean  "black",                    :default => false
    t.string   "move_queue", :limit => 20
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "matches", :force => true do |t|
    t.integer  "active",                        :default => 1
    t.string   "start_pos",      :limit => 100
    t.string   "result",         :limit => 10
    t.integer  "winning_player"
    t.string   "name",           :limit => 100
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "moves", :force => true do |t|
    t.integer  "match_id"
    t.string   "from_coord",           :limit => 10
    t.string   "to_coord",             :limit => 10
    t.integer  "move_num",                           :default => 0
    t.string   "notation",             :limit => 10
    t.integer  "castled"
    t.string   "captured_piece_coord", :limit => 10
    t.string   "promotion_choice",     :limit => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "players", :force => true do |t|
    t.string "name", :limit => 20
  end

  add_index "players", ["name"], :name => "index_players_on_name", :unique => true

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.string   "email",              :limit => 50
    t.integer  "playing_as"
    t.string   "security_phrase",    :limit => 200
    t.string   "auth_token",         :limit => 200
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password", :limit => 128
    t.string   "salt",               :limit => 128
    t.string   "confirmation_token", :limit => 128
    t.string   "remember_token",     :limit => 128
    t.boolean  "email_confirmed",                   :default => false, :null => false
    t.boolean  "admin",                             :default => false, :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["id", "confirmation_token"], :name => "index_users_on_id_and_confirmation_token"
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end
