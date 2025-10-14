class Subscription < ApplicationRecord
  belongs_to :account

  validates :account, presence: true
  validates :polar_subscription_id, presence: true
  validates :status, presence: true

  def active?
    status == "active"
  end

  def cancelled?
    cancelled_at.present?
  end

  def trial?
    status == "trialing"
  end

  def past_due?
    status == "past_due"
  end
end
