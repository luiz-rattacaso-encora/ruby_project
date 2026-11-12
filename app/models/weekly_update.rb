class WeeklyUpdate < ApplicationRecord
  belongs_to :team
  belongs_to :author, class_name: "Employee"

  validates :content, :team_id, :author_id, presence: true

  enum :status, { draft: "draft", published: "published", archived: "archived" }, default: :draft

  before_save :set_published_date, if: :will_save_change_to_status?

  scope :by_author_name, ->(name) {
    if name.present?
      joins(:author).where("CONCAT(employees.first_name, ' ', employees.last_name) LIKE ?", "%#{name}%")
    end
  }
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :last_week, ->(from_date, to_date) { where(updated_at: from_date..to_date) } # .. é uma delimitação de tempo entre um e outro

  private

  def set_published_date
    if published? && published_date.nil?
      self.published_date = Time.current
    end
  end
end
