class AddAuthorAndPublishedDateToWeeklyUpdates < ActiveRecord::Migration[8.1]
  def change
    add_reference :weekly_updates, :author, foreign_key: { to_table: :employees }
    add_column :weekly_updates, :published_date, :datetime
  end
end
