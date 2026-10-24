class CreateOperadors < ActiveRecord::Migration[8.1]
  def change
    create_table :operadors do |t|
      t.timestamps
    end
  end
end
