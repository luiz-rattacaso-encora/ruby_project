class CreateWeeklyUpdates < ActiveRecord::Migration[8.1]
  def change
    create_table :weekly_updates do |t|
      t.text :content
      t.string :status
      t.references :team, null: false, foreign_key: true

      t.timestamps
    end
  end
end
