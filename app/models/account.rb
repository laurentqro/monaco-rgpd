class Account < ApplicationRecord
  belongs_to :owner, class_name: "User", optional: true
  has_many :users, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_one :active_subscription, -> { where(status: "active") }, class_name: "Subscription"

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: true,
    format: {
      with: /\A[a-z0-9-]+\z/,
      message: "only allows lowercase letters, numbers, and hyphens"
    }

  def subscribed?
    active_subscription.present?
  end

  def onboarding_completed?
    onboarding_completed_at.present?
  end
end
