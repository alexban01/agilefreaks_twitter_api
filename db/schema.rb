# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_16_211500) do
  create_table "images", force: :cascade do |t|
    t.integer "byte_size"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "url"
  end

  create_table "resource_descriptions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.integer "image_id", null: false
    t.string "owner_id", null: false
    t.string "owner_type", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["image_id"], name: "index_resource_descriptions_on_image_id"
    t.index ["owner_type", "owner_id"], name: "index_resource_descriptions_on_owner"
  end

  create_table "tweets", primary_key: "uuid", id: :string, force: :cascade do |t|
    t.string "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "resource_descriptions", "images"
end
