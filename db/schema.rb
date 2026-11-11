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

ActiveRecord::Schema[8.1].define(version: 2026_11_10_000002) do
  create_table "refeicoes", force: :cascade do |t|
    t.date "data", null: false
    t.string "tipo", null: false
    t.time "inicio", null: false
    t.time "fim", null: false
    t.text "opcao_padrao", null: false
    t.text "opcao_ovolactovegetariana", null: false
    t.text "opcao_vegetariana_estrita", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data", "tipo"], name: "index_refeicoes_on_data_and_tipo", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "nome", null: false
    t.string "matricula"
    t.string "siape"
    t.string "sigaa"
    t.string "role", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["matricula"], name: "index_users_on_matricula", unique: true
    t.index ["siape"], name: "index_users_on_siape", unique: true
    t.index ["sigaa"], name: "index_users_on_sigaa", unique: true
  end
end
