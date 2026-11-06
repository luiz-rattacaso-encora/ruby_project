class Membership < ApplicationRecord
  belongs_to :employee
  belongs_to :team

  validates :employee_id, :team_id, presence: true
  validates :employee_id, uniqueness: { scope: :team_id, conditions: -> { where(finished_at: nil) }, message: "is already an active member of this team" }, if: :is_active_membership?

  private

  def is_active_membership?
    finished_at.nil?
  end
end
