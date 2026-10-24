class AddCredenciaisToOperadors < ActiveRecord::Migration[8.1]
  def change
    add_column :operadors, :identificacao, :string
    add_column :operadors, :password_digest, :string
    add_index :operadors, :identificacao, unique: true
  end
end
