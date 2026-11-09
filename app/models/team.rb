class Team < ApplicationRecord
  validates :name, :description, :technologies, presence: true
  validates :name, uniqueness: true

  has_many :memberships, dependent: :destroy
  has_many :employees, through: :memberships

  attribute :technologies, :json, default: []

  scope :by_name, ->(name) { where("name LIKE ?", "%#{name}%") if name.present? }
end
