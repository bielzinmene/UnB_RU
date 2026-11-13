class CriarOperacaoDeAcesso < ActiveRecord::Migration[8.1]
  def change
    create_table :restaurantes do |t|
      t.string :nome, null: false
      t.string :campus, null: false
      t.boolean :ativo, default: true, null: false
      t.timestamps
    end

    add_index :restaurantes, [ :nome, :campus ], unique: true

    create_table :pontos_acessos do |t|
      t.references :restaurante, null: false, foreign_key: true
      t.string :identificador, null: false
      t.string :nome, null: false
      t.string :campus, null: false
      t.string :status, default: "Ativo", null: false
      t.timestamps
    end

    add_index :pontos_acessos, :identificador, unique: true
    add_check_constraint :pontos_acessos,
      "status IN ('Ativo', 'Inativo')",
      name: "status_do_ponto_de_acesso_valido"

    create_table :acessos do |t|
      t.references :ponto_acesso,
        null: false,
        foreign_key: { to_table: :pontos_acessos }
      t.references :user, null: true, foreign_key: true
      t.string :matricula, null: false
      t.datetime :ocorrido_em, null: false
      t.string :refeicao, null: false
      t.string :resultado, null: false
      t.string :motivo
      t.decimal :valor_debitado,
        precision: 10,
        scale: 2,
        default: 0,
        null: false
      t.timestamps
    end

    add_index :acessos, [ :ponto_acesso_id, :ocorrido_em ]
    add_index :acessos, [ :ocorrido_em, :refeicao ]
    add_check_constraint :acessos,
      "resultado IN ('Liberado', 'Bloqueado')",
      name: "resultado_do_acesso_valido"
    add_check_constraint :acessos,
      "valor_debitado >= 0",
      name: "valor_debitado_do_acesso_valido"
  end
end
