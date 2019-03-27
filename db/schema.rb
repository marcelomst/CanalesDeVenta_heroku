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

ActiveRecord::Schema.define(version: 20190315180746) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "reservas", force: :cascade do |t|
    t.integer  "id_channel"
    t.string   "special_offer"
    t.integer  "reservation_code",         limit: 8
    t.string   "arrival_hour"
    t.integer  "booked_rate"
    t.string   "rooms"
    t.string   "customer_mail"
    t.string   "customer_country"
    t.integer  "children"
    t.string   "payment_gateway_fee"
    t.string   "customer_surname"
    t.string   "date_departure"
    t.integer  "forced_price"
    t.string   "amount_reason"
    t.string   "customer_city"
    t.integer  "opportunities"
    t.string   "date_received"
    t.integer  "was_modified"
    t.string   "sessionSeed"
    t.string   "customer_name"
    t.string   "date_arrival"
    t.integer  "status"
    t.string   "channel_reservation_code"
    t.string   "customer_phone"
    t.float    "orig_amount"
    t.integer  "men"
    t.string   "customer_notes"
    t.string   "customer_address"
    t.string   "status_reason"
    t.integer  "roomnight"
    t.integer  "customer_language"
    t.string   "fount"
    t.string   "customer_zip"
    t.float    "amount"
    t.integer  "cc_info"
    t.integer  "room_opportunities"
    t.string   "customer_language_iso"
    t.text     "booked_rooms"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reservas", ["reservation_code"], name: "index_reservas_on_reservation_code", using: :btree

  create_table "rooms", force: :cascade do |t|
    t.integer  "id_room"
    t.integer  "reserva_id"
    t.integer  "occupancy"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rooms", ["id_room"], name: "index_rooms_on_id_room", using: :btree
  add_index "rooms", ["reserva_id"], name: "index_rooms_on_reserva_id", using: :btree

  create_table "solicituds", force: :cascade do |t|
    t.integer  "id_solicitud",         limit: 8
    t.string   "lname"
    t.string   "fname"
    t.string   "email"
    t.string   "city"
    t.string   "phone"
    t.string   "street"
    t.string   "country"
    t.string   "arrival_hour"
    t.string   "notes"
    t.float    "amount"
    t.text     "rooms"
    t.string   "dfrom"
    t.string   "dto"
    t.integer  "reservation_code",     limit: 8
    t.integer  "estado",                         default: 0, null: false
    t.integer  "reservation_code_ota", limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "solicituds", ["id_solicitud"], name: "index_solicituds_on_id_solicitud", using: :btree
  add_index "solicituds", ["reservation_code"], name: "index_solicituds_on_reservation_code", using: :btree
  add_index "solicituds", ["reservation_code_ota"], name: "index_solicituds_on_reservation_code_ota", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "subdomain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "widgets", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "stock"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
