class Employee < ApplicationRecord
  validates :first_name, :last_name, :role, presence: true

  belongs_to :manager, class_name: "Employee", optional: true

  has_many :team_members, class_name: "Employee", foreign_key: "manager_id"

  def full_name_with_role
    "#{first_name} #{last_name} (#{role})"
  end
end
