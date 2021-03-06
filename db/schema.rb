# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130203191715) do

  create_table "scrape_events", :force => true do |t|
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "ubu_entries_count", :default => 0
  end

  create_table "settings", :force => true do |t|
    t.string   "key"
    t.string   "label"
    t.string   "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "settings", ["key"], :name => "index_settings_on_key", :unique => true

  create_table "ubu_entries", :force => true do |t|
    t.integer  "entry_type"
    t.string   "title"
    t.string   "href"
    t.text     "description"
    t.string   "artist"
    t.integer  "scrape_event_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

end
