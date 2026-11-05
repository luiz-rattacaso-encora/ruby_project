class User < ApplicationRecord
  validates :email_address, uniqueness: true, presence: true

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_one :employee, dependent: :nullify

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
