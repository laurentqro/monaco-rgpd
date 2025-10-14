class Account < ApplicationRecord
  belongs_to :owner, class_name: "User", optional: true
  has_many :users, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_one :active_subscription, -> { where(status: "active") }, class_name: "Subscription"
  has_many :compliance_assessments, dependent: :destroy
  has_many :responses, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :processing_activities, dependent: :destroy

  enum :account_type, {
    solopreneur: 0,
    company: 1,
    consultant: 2
  }, prefix: true

  enum :compliance_mode, {
    simple: 0,
    modular: 1
  }, prefix: true

  enum :entity_type, {
    company: 0,
    ngo: 1,
    government: 2,
    association: 3
  }, prefix: true

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: true,
    format: {
      with: /\A[a-z0-9-]+\z/,
      message: "only allows lowercase letters, numbers, and hyphens"
    }
  validates :jurisdiction, presence: true
  validates :account_type, presence: true

  # Set compliance_mode based on account_type
  before_validation :set_compliance_mode, on: :create

  def subscribed?
    active_subscription.present?
  end

  def onboarding_completed?
    onboarding_completed_at.present?
  end

  private

  def set_compliance_mode
    self.compliance_mode ||= account_type_solopreneur? ? :simple : :modular
  end
end
