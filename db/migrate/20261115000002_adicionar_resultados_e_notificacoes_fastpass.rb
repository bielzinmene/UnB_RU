class AdicionarResultadosENotificacoesFastpass < ActiveRecord::Migration[8.1]
  def change
    add_column :turnos_fastpass, :sorteio_concluido_em, :datetime
    add_column :inscricoes_fastpass, :sorteado, :boolean

    create_table :notificacoes_fastpass do |t|
      t.references :inscricao_fastpass, null: false,
        foreign_key: { to_table: :inscricoes_fastpass }, index: { unique: true }
      t.string :mensagem, null: false
      t.datetime :enviada_em, null: false
      t.timestamps
    end
  end
end
