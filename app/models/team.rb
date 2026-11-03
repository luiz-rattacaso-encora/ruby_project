class Team < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :employees, through: :memberships

  attribute :programming_languages, :json, default: []
end
