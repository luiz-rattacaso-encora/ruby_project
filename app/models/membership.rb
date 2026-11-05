class Membership < ApplicationRecord
  validates :employee_id, :team_id, presence: true
  validates :employee_id, uniqueness: { scope: :team_id, message: "already at this team" }

  belongs_to :employee
  belongs_to :team
end
