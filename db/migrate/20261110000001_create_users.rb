class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :nome, null: false
      t.string :matricula
      t.string :siape
      t.string :sigaa
      t.string :role, null: false
      t.string :password_digest, null: false
      t.timestamps
    end

    add_index :users, :matricula, unique: true
    add_index :users, :siape, unique: true
    add_index :users, :sigaa, unique: true
  end
end
