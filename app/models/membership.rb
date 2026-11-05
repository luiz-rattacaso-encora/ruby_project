class Membership < ApplicationRecord
  validates :employee_id, :team_id, presence: true

  belongs_to :employee
  belongs_to :team
end
