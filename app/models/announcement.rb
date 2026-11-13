class Announcement < ApplicationRecord
  belongs_to :author, class_name: "Employee", foreign_key: :employee_id
  belongs_to :team, optional: true

  validates :title, :content, presence: true
  validate :author_must_belong_to_team

  scope :by_team, ->(team_id) { where(team_id: team_id) if team_id.present? }

  scope :by_author_name, ->(name) {
    if name.present?
      # joins = inner join pq o "author" apenas aponta para a table mãe
      joins(:author).where("CONCAT(employees.first_name, ' ', employees.last_name) ILIKE ?", "%#{name}%")
    end
  }

  def author_must_belong_to_team
    return if team_id.blank? || author.blank?

    unless Membership.exists?(employee_id: author.id, team_id: team_id, finished_at: nil)
      errors.add(:team_id, "Does not has an active relationship with this team anymore")
    end
  end
end
