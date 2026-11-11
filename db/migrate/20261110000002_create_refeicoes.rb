class CreateRefeicoes < ActiveRecord::Migration[8.1]
  def change
    create_table :refeicoes do |t|
      t.date :data, null: false
      t.string :tipo, null: false
      t.time :inicio, null: false
      t.time :fim, null: false
      t.text :opcao_padrao, null: false
      t.text :opcao_ovolactovegetariana, null: false
      t.text :opcao_vegetariana_estrita, null: false
      t.timestamps
    end

    add_index :refeicoes, [ :data, :tipo ], unique: true
  end
end
