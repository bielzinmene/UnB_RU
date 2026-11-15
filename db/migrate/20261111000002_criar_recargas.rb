class CriarRecargas < ActiveRecord::Migration[8.1]
  def change
    create_table :recargas do |t|
      t.references :user, null: false, foreign_key: true

      t.decimal :valor,
        precision: 10,
        scale: 2,
        null: false

      t.string :forma_pagamento, null: false

      t.string :situacao,
        default: "pendente",
        null: false

      t.string :codigo_pix
      t.datetime :expira_em
      t.datetime :confirmada_em

      t.timestamps
    end

    add_check_constraint :recargas,
      "valor > 0 AND valor <= 500",
      name: "valor_da_recarga_valido"

    add_check_constraint :recargas,
      "forma_pagamento IN ('pix', 'cartao')",
      name: "forma_de_pagamento_valida"

    add_check_constraint :recargas,
      "situacao IN ('pendente', 'confirmada', 'cancelada')",
      name: "situacao_da_recarga_valida"
  end
end
