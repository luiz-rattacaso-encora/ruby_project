class Team < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :employees, through: :memberships

  attribute :technologies, :json, default: []
end
