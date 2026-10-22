class AddColumnIsManagerToEmployee < ActiveRecord::Migration[8.1]
  def change
    add_column :employees, :is_manager, :boolean, default: false, null: false
  end
end
