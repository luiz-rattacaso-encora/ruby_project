class AddColumnFinishedAtToMemberships < ActiveRecord::Migration[8.1]
  def change
    add_column :memberships, :finished_at, :datetime
  end
end
