class AllowNullManagerInEmployees < ActiveRecord::Migration[8.1]
  def change
    change_column_null :employees, :manager_id, true
  end
end
