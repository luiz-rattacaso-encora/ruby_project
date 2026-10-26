class AddColumnLastNameToEmployee < ActiveRecord::Migration[8.1]
  def change
    add_column :employees, :last_name, :string
    rename_column :employees, :name, :first_name

    reversible do |dir|
      dir.up do
        Employee.reset_column_information

        Employee.all.each do |employee|
          next if employee.first_name.blank?

          parts = employee.first_name.strip.split(' ', 2)

          if parts.length > 1
            employee.update_columns(first_name: parts[0], last_name: parts[1])
          else
            employee.update_columns(last_name: "")
          end
        end
      end
    end

    change_column_null :employees, :last_name, false, ""
    change_column_null :employees, :first_name, false
  end
end
