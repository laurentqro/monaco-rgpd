class Admin < ApplicationRecord
  has_secure_password
  has_many :admin_sessions, dependent: :destroy

  validates :email, presence: true, uniqueness: true,
    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :password, length: { minimum: 8 }, allow_nil: true

  normalizes :email, with: ->(e) { e.strip.downcase }
end
