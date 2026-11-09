class WeeklyUpdate < ApplicationRecord
  belongs_to :team
  validates :content, :team_id, presence: true

  enum :status, { draft: "draft", published: "published", archived: "archived" }, default: :draft
end
