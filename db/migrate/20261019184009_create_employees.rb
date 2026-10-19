class CreateEmployees < ActiveRecord::Migration[8.1]
  def change
    create_table :employees do |t|
      t.string :name
      t.string :role
      t.references :manager, null: true, foreign_key: { to_table: :employees }

      t.timestamps
    end
  end
end
