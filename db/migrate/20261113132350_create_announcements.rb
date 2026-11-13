class CreateAnnouncements < ActiveRecord::Migration[8.1]
  def change
    create_table :announcements do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.references :employee, null: false, foreign_key: true
      t.references :team, null: true, foreign_key: true

      t.timestamps
    end
  end
end
