class RenameColumnLanguagesToTechnologies < ActiveRecord::Migration[8.1]
  def change
    rename_column :teams, :languages, :technologies
  end
end
