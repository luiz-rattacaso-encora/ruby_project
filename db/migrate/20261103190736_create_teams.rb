class CreateTeams < ActiveRecord::Migration[8.1]
  def change
    create_table :teams do |t|
      t.string :name
      t.text :description
      t.json :languages

      t.timestamps
    end
  end
end
