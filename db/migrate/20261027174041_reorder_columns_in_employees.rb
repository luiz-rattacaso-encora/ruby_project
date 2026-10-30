class ReorderColumnsInEmployees < ActiveRecord::Migration[8.1]
  def change
    change_column :employees, :last_name, :string, after: :first_name
    change_column :employees, :user_id, :bigint, after: :last_name
  end
end
