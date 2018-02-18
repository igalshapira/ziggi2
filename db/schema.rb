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

ActiveRecord::Schema.define(:version => 20150904161039) do

  create_table "authorizations", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "beer_notifications", :force => true do |t|
    t.text     "params"
    t.integer  "user_id"
    t.string   "status"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.boolean  "ack"
  end

  create_table "course_groups", :force => true do |t|
    t.integer  "course_id"
    t.integer  "number"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "group_type"
    t.integer  "staff_id"
  end

  create_table "courses", :force => true do |t|
    t.string   "number"
    t.string   "name"
    t.integer  "semester_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.float    "hours"
    t.float    "points"
    t.string   "homepage"
  end

  create_table "events", :force => true do |t|
    t.integer  "user_id",       :default => 0
    t.string   "location"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.string   "title",                            :null => false
    t.integer  "color"
    t.integer  "course_id",     :default => 0
    t.datetime "date_start"
    t.datetime "date_end"
    t.boolean  "public",        :default => false
    t.boolean  "weekly",        :default => false
    t.integer  "university_id", :default => 0
    t.integer  "staff_id",      :default => 0
  end

  create_table "group_hours", :force => true do |t|
    t.integer  "coursegroup_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "room"
    t.datetime "date_start"
    t.datetime "date_end"
    t.integer  "building_id"
    t.integer  "room_number"
  end

  create_table "logins", :force => true do |t|
    t.string   "ip"
    t.string   "browser"
    t.string   "provider"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "user_id"
  end

  create_table "recoveries", :force => true do |t|
    t.integer  "user_id"
    t.string   "recover_hash"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "rooms", :force => true do |t|
    t.string   "name"
    t.text     "comment"
    t.float    "lat"
    t.float    "lng"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "university_id"
  end

  create_table "searches", :force => true do |t|
    t.integer  "semester_id"
    t.string   "search"
    t.text     "results"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "semesters", :force => true do |t|
    t.string   "name"
    t.integer  "year"
    t.integer  "semester"
    t.integer  "university_id"
    t.date     "start"
    t.date     "end"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.date     "exams_start"
    t.date     "exams_end"
    t.boolean  "active",        :default => false
  end

  create_table "shares", :force => true do |t|
    t.integer  "user_id"
    t.string   "share_hash"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "staff_ranks", :force => true do |t|
    t.integer  "staff_id"
    t.integer  "user_id"
    t.integer  "rank"
    t.string   "comment"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "staffs", :force => true do |t|
    t.string   "name"
    t.string   "phone"
    t.string   "room"
    t.string   "email"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "user_id",    :default => 0
    t.string   "reception"
  end

  create_table "universities", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "homepage"
    t.float    "lat"
    t.float    "lng"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "status",     :default => 0
  end

  create_table "user_courses", :force => true do |t|
    t.integer  "user_id"
    t.integer  "course_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "group"
  end

  create_table "user_events", :force => true do |t|
    t.integer  "event_id"
    t.boolean  "selected",   :default => true
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "user_id"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "gender"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "semester_id",    :default => 0
    t.datetime "birthdate"
    t.integer  "year_in_degree"
    t.integer  "department"
    t.integer  "degree"
  end

end
