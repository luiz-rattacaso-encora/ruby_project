class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :role
      t.string :reports_to
      t.boolean :is_manager
      t.string :subordinates
      t.timestamps
    end
  end
end
