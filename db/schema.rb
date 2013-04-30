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

ActiveRecord::Schema.define(:version => 20130424030223) do

  create_table "administrators", :force => true do |t|
    t.string   "name",            :limit => 16
    t.string   "password_digest", :limit => 60
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.text     "session_state"
  end

  create_table "affiliations", :force => true do |t|
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "team_id",          :default => 0, :null => false
    t.integer  "local_contest_id", :default => 0, :null => false
  end

  create_table "designs", :force => true do |t|
    t.integer  "team_id",                   :default => 0,  :null => false
    t.integer  "score",                     :default => 0,  :null => false
    t.integer  "sequence",                  :default => 0,  :null => false
    t.string   "scenario",    :limit => 10, :default => "", :null => false
    t.text     "bridge"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "hash_string", :limit => 40
  end

  create_table "environments", :force => true do |t|
    t.string   "tag",        :limit => 40
    t.string   "key",        :limit => 16
    t.string   "value"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
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
    t.integer  "age",                          :default => 0,     :null => false
    t.integer  "grade",                        :default => 0,     :null => false
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
    t.integer  "team_id",                      :default => 0,     :null => false
    t.string   "country",        :limit => 40, :default => "USA"
    t.integer  "rank",                         :default => 0,     :null => false
  end

  create_table "scoreboards", :force => true do |t|
    t.string   "category",   :limit => 1
    t.string   "status",     :limit => 1
    t.text     "board"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.integer  "admin_id",                :null => false
  end

  create_table "sequence_numbers", :force => true do |t|
    t.string   "tag",        :limit => 8,                :null => false
    t.integer  "value",                   :default => 0, :null => false
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  create_table "teams", :force => true do |t|
    t.string   "name",            :limit => 32
    t.string   "name_key",        :limit => 32
    t.string   "email",           :limit => 40
    t.integer  "submits",                       :default => 0,   :null => false
    t.integer  "improves",                      :default => 0,   :null => false
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.string   "password_digest", :limit => 60
    t.string   "category",        :limit => 4
    t.datetime "reg_completed"
    t.string   "status",          :limit => 1,  :default => "-", :null => false
    t.integer  "group_id"
  end

end
