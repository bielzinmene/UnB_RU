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

ActiveRecord::Schema[8.1].define(version: 2026_11_12_000001) do
  create_table "consumos", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "restaurante", null: false
    t.decimal "valor_debitado", precision: 10, scale: 2, null: false
    t.datetime "ocorrido_em", null: false
    t.string "referencia", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["referencia"], name: "index_consumos_on_referencia", unique: true
    t.index ["user_id", "ocorrido_em"], name: "index_consumos_on_user_id_and_ocorrido_em"
    t.index ["user_id"], name: "index_consumos_on_user_id"
    t.check_constraint "valor_debitado >= 0", name: "valor_do_consumo_valido"
  end

  create_table "recargas", force: :cascade do |t|
    t.integer "user_id", null: false
    t.decimal "valor", precision: 10, scale: 2, null: false
    t.string "forma_pagamento", null: false
    t.string "situacao", default: "pendente", null: false
    t.string "codigo_pix"
    t.datetime "expira_em"
    t.datetime "confirmada_em"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_recargas_on_user_id"
    t.check_constraint "forma_pagamento IN ('pix', 'cartao')", name: "forma_de_pagamento_valida"
    t.check_constraint "situacao IN ('pendente', 'confirmada', 'cancelada')", name: "situacao_da_recarga_valida"
    t.check_constraint "valor > 0 AND valor <= 500", name: "valor_da_recarga_valido"
  end

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
    t.decimal "saldo", precision: 10, scale: 2, default: "0.0", null: false
    t.string "grupo_pagamento", default: "2", null: false
    t.index ["matricula"], name: "index_users_on_matricula", unique: true
    t.index ["siape"], name: "index_users_on_siape", unique: true
    t.index ["sigaa"], name: "index_users_on_sigaa", unique: true
    t.check_constraint "grupo_pagamento IN ('1', '2', '3')", name: "grupo_pagamento_valido"
    t.check_constraint "saldo >= 0 AND saldo <= 500", name: "saldo_dentro_do_limite"
  end

  add_foreign_key "consumos", "users"
  add_foreign_key "recargas", "users"
end
