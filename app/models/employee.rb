class Employee < ApplicationRecord
  validates :first_name, :last_name, :role, presence: true

  belongs_to :manager, class_name: "Employee", optional: true
  belongs_to :user, optional: true
  has_many :team_members, class_name: "Employee", foreign_key: "manager_id"

  accepts_nested_attributes_for :user
  before_validation :set_default_user_password, on: :create

  def full_name_with_role
    "#{first_name} #{last_name} (#{role})"
  end

  private
  def set_default_user_password
    if user && user.password.blank?
      user.password = first_name
      user.password_confirmation = first_name
    end
  end
end
