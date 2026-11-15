class CriarTurnosEFaixasFastpass < ActiveRecord::Migration[8.1]
  def change
    create_table :turnos_fastpass do |t|
      t.date :data, null: false
      t.string :tipo_refeicao, null: false
      t.string :inicio, null: false
      t.string :fim, null: false
      t.timestamps
    end
    add_index :turnos_fastpass, [ :data, :tipo_refeicao ], unique: true

    create_table :faixas_fastpass do |t|
      t.references :turno_fastpass, null: false, foreign_key: { to_table: :turnos_fastpass }
      t.string :inicio, null: false
      t.string :fim, null: false
      t.timestamps
    end
  end
end
