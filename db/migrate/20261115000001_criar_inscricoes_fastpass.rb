class CriarInscricoesFastpass < ActiveRecord::Migration[8.1]
  def change
    create_table :inscricoes_fastpass do |t|
      t.references :user, null: false, foreign_key: true
      t.references :turno_fastpass, null: false, foreign_key: { to_table: :turnos_fastpass }
      t.references :faixa_fastpass, null: false, foreign_key: { to_table: :faixas_fastpass }
      t.timestamps
    end

    add_index :inscricoes_fastpass, [ :user_id, :turno_fastpass_id ], unique: true,
      name: "index_inscricoes_fastpass_on_user_and_turno"
  end
end
