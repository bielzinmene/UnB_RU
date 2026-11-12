class CriarConsumos < ActiveRecord::Migration[8.1]
  def change
    create_table :consumos do |t|
      t.references :user, null: false, foreign_key: true

      t.string :restaurante, null: false

      t.decimal :valor_debitado,
        precision: 10,
        scale: 2,
        null: false

      t.datetime :ocorrido_em, null: false
      t.string :referencia, null: false

      t.timestamps
    end

    add_index :consumos, :referencia, unique: true
    add_index :consumos, [ :user_id, :ocorrido_em ]

    add_check_constraint :consumos,
      "valor_debitado >= 0",
      name: "valor_do_consumo_valido"
  end
end
