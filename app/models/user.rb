class User < ApplicationRecord
  belongs_to :account
  has_many :sessions, dependent: :destroy
  has_many :magic_links, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :responses, foreign_key: :respondent_id, dependent: :destroy

  enum :role, { member: 0, admin: 1, owner: 2 }

  validates :email, presence: true, uniqueness: true,
    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :account, presence: true

  normalizes :email, with: ->(e) { e.strip.downcase }

  def admin?
    role_before_type_cast >= self.class.roles[:admin]
  end
end
