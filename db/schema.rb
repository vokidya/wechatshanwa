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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150519110444) do

  create_table "qa_voices", force: :cascade do |t|
    t.string   "voice_type"
    t.string   "voice_media_id"
    t.string   "voice_text"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "studies", force: :cascade do |t|
    t.string   "question"
    t.string   "answer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "wechat_configs", force: :cascade do |t|
    t.string   "key_name"
    t.string   "key_value"
    t.string   "key_expired_time"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "wechatlog_statuses", force: :cascade do |t|
    t.integer  "log_id"
    t.string   "log_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "wechatlogs", force: :cascade do |t|
    t.string   "logkey"
    t.string   "logvalue"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "log_recognition"
  end

end
