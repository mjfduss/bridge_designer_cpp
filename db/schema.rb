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

ActiveRecord::Schema.define(:version => 20131107042214) do

  create_table "administrators", :force => true do |t|
    t.string   "name",            :limit => 16
    t.string   "password_digest", :limit => 60
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.text     "session_state"
  end

  add_index "administrators", ["name"], :name => "index_administrators_on_name", :unique => true

  create_table "affiliations", :force => true do |t|
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "team_id",          :default => 0, :null => false
    t.integer  "local_contest_id", :default => 0, :null => false
  end

  add_index "affiliations", ["local_contest_id"], :name => "index_affiliations_on_local_contest_id"
  add_index "affiliations", ["team_id"], :name => "index_affiliations_on_team_id"

  create_table "bests", :force => true do |t|
    t.integer  "team_id",                  :null => false
    t.integer  "design_id",                :null => false
    t.string   "scenario",   :limit => 10
    t.integer  "score",      :limit => 8,  :null => false
    t.integer  "sequence",                 :null => false
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "bests", ["scenario"], :name => "index_bests_on_scenario"
  add_index "bests", ["score", "sequence"], :name => "index_bests_on_score_and_sequence"
  add_index "bests", ["team_id"], :name => "index_bests_on_team_id"

  create_table "ckeditor_assets", :force => true do |t|
    t.string   "data_file_name",                  :null => false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    :limit => 30
    t.string   "type",              :limit => 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], :name => "idx_ckeditor_assetable"
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], :name => "idx_ckeditor_assetable_type"

  create_table "ckeditor_assets_contents", :force => true do |t|
    t.integer "ckeditor_asset_id"
    t.string  "style"
    t.binary  "file_contents"
  end

  add_index "ckeditor_assets_contents", ["ckeditor_asset_id"], :name => "index_ckeditor_assets_contents_on_ckeditor_asset_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "designs", :force => true do |t|
    t.integer  "team_id",                   :default => 0,  :null => false
    t.integer  "score",       :limit => 8,  :default => 0,  :null => false
    t.integer  "sequence",                  :default => 0,  :null => false
    t.string   "scenario",    :limit => 10, :default => "", :null => false
    t.text     "bridge"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "hash_string", :limit => 40
  end

  add_index "designs", ["hash_string"], :name => "index_designs_on_hash_string"
  add_index "designs", ["team_id", "score", "sequence"], :name => "index_designs_on_team_id_and_score_and_sequence"

  create_table "groups", :force => true do |t|
    t.string   "description", :limit => 40
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "html_documents", :force => true do |t|
    t.string   "subject",    :null => false
    t.text     "text",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.integer  "affiliations_count",               :default => 0, :null => false
  end

  add_index "local_contests", ["code"], :name => "index_local_contests_on_code", :unique => true

  create_table "local_scoreboards", :force => true do |t|
    t.string   "code"
    t.integer  "page"
    t.text     "board"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "local_scoreboards", ["code", "page"], :name => "index_local_scoreboards_on_code_and_page"

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

  add_index "members", ["team_id"], :name => "index_members_on_team_id"

  create_table "parents", :force => true do |t|
    t.string   "first_name",     :limit => 40
    t.string   "middle_initial", :limit => 1
    t.string   "last_name",      :limit => 40
    t.string   "email",          :limit => 40
    t.integer  "member_id"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "password_resets", :force => true do |t|
    t.string   "key"
    t.integer  "team_id",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "password_resets", ["key"], :name => "index_password_resets_on_key", :unique => true
  add_index "password_resets", ["team_id"], :name => "index_password_resets_on_team_id", :unique => true

  create_table "reminder_requests", :force => true do |t|
    t.string   "referer"
    t.string   "tag"
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "schedules", :force => true do |t|
    t.string   "name",                  :limit => 40,                    :null => false
    t.boolean  "active",                              :default => false, :null => false
    t.boolean  "closed",                                                 :null => false
    t.text     "message",                                                :null => false
    t.datetime "start_quals_prereg",                                     :null => false
    t.datetime "start_quals",                                            :null => false
    t.datetime "end_quals",                                              :null => false
    t.boolean  "quals_tally_complete",                                   :null => false
    t.datetime "start_semis_prereg",                                     :null => false
    t.datetime "start_semis",                                            :null => false
    t.datetime "end_semis",                                              :null => false
    t.datetime "created_at",                                             :null => false
    t.datetime "updated_at",                                             :null => false
    t.integer  "semis_instructions_id"
  end

  create_table "scoreboards", :force => true do |t|
    t.string   "category",   :limit => 1
    t.string   "status",     :limit => 1
    t.text     "board"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.integer  "admin_id",                :null => false
  end

  add_index "scoreboards", ["admin_id", "status"], :name => "index_scoreboards_on_admin_id_and_status"

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

  add_index "teams", ["email"], :name => "index_teams_on_email"
  add_index "teams", ["name_key"], :name => "index_teams_on_name_key", :unique => true

end
