class Employee < ApplicationRecord
  validates :first_name, :last_name, :role, presence: true

  belongs_to :manager, class_name: "Employee", optional: true
  belongs_to :user, dependent: :destroy

  has_many :team_members, class_name: "Employee", foreign_key: "manager_id", dependent: nullify
  has_many :memberships, dependent: :destroy
  has_many :active_memberships, -> { where(finished_at: nil) }, class_name: "Membership"
  has_many :teams, through: :memberships
  has_many :active_teams, through: :active_memberships, source: :team
  has_many :weekly_updates, foreign_key: "author_id", dependent: :nullify
  has_many :announcements, dependent: :destroy

  accepts_nested_attributes_for :user
  before_validation :set_default_user_password, on: :create

  scope :by_name, ->(name) {
    if name.present?
      where("CONCAT(first_name, ' ', last_name) LIKE ?", "%#{name}%")
    end
  }

  def full_name_with_role
    "#{first_name} #{last_name} (#{role})"
  end

  def name
    "#{first_name} #{last_name}".strip
  end

  def reports_to
    list = []
    current_manager = manager

    while current_manager
      list.unshift(current_manager)
      current_manager = current_manager.manager
    end
    list
  end

  private
  def set_default_user_password
    if user && user.password.blank?
      user.password = first_name
      user.password_confirmation = first_name
    end
  end
end
