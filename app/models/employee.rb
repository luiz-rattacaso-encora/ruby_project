class Employee < ApplicationRecord
  validates :first_name, :last_name, :role, :manager_id, presence: true

  belongs_to :manager, class_name: "Employee", optional: true

  has_many :team_members, class_name: "Employee", foreign_key: "manager_id"
end
