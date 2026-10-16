class UpdateUsersIsManager < ActiveRecord::Migration[8.1]
  def change
    change_column_default :users, :is_manager, from: true, to: false
  end
end
