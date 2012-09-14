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

ActiveRecord::Schema.define(:version => 20120911043556) do

  create_table "affiliations", :force => true do |t|
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "team_id"
    t.integer  "local_contest_id"
  end

  create_table "designs", :force => true do |t|
    t.integer  "team_id"
    t.integer  "score"
    t.integer  "sequence"
    t.integer  "scenario"
    t.text     "bridge"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "groups", :force => true do |t|
    t.string   "description", :limit => 40
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "local_contests", :force => true do |t|
    t.string   "code",               :limit => 8
    t.string   "description",        :limit => 40
    t.string   "poc_first_name",     :limit => 40
    t.string   "poc_middle_initial", :limit => 1
    t.string   "poc_last_name",      :limit => 40
    t.string   "poc_position",       :limit => 40
    t.string   "organization",       :limit => 40
    t.string   "city",               :limit => 40
    t.string   "state",              :limit => 40
    t.string   "zip",                :limit => 9
    t.string   "phone",              :limit => 16
    t.string   "link",               :limit => 40
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "members", :force => true do |t|
    t.string   "first_name",     :limit => 40
    t.string   "middle_initial", :limit => 1
    t.string   "last_name",      :limit => 40
    t.string   "category",       :limit => 1
    t.integer  "age"
    t.integer  "grade"
    t.string   "phone",          :limit => 16
    t.string   "street",         :limit => 40
    t.string   "city",           :limit => 40
    t.string   "state",          :limit => 40
    t.string   "zip",            :limit => 16
    t.string   "school",         :limit => 40
    t.string   "school_city",    :limit => 40
    t.string   "sex",            :limit => 1
    t.string   "hispanic",       :limit => 1
    t.string   "race",           :limit => 1
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.string   "reg_state",      :limit => 2
    t.integer  "team_id"
    t.string   "country",        :limit => 40, :default => "USA"
  end

  create_table "teams", :force => true do |t|
    t.string   "name",            :limit => 32
    t.string   "name_key",        :limit => 32
    t.string   "email",           :limit => 40
    t.integer  "submits"
    t.integer  "improves"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "captain_id"
    t.string   "password_digest", :limit => 60
    t.string   "category",        :limit => 4
    t.datetime "reg_completed"
  end

end
