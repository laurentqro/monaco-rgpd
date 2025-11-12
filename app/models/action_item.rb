class ActionItem < ApplicationRecord
  belongs_to :account
  belongs_to :actionable, polymorphic: true

  enum :source, { assessment: 0, regulatory_deadline: 1, system_recommendation: 2 }
  enum :priority, { low: 0, medium: 1, high: 2, critical: 3 }
  enum :status, { pending: 0, in_progress: 1, completed: 2, dismissed: 3 }
  enum :action_type, {
    update_treatment: 0,
    generate_document: 1,
    complete_wizard: 2,
    respond_to_sar: 3,
    notify_breach: 4
  }

  validates :title, presence: true
  validates :source, presence: true

  scope :for_account, ->(account) { where(account: account) }
  scope :pending, -> { where(status: :pending) }
  scope :by_priority, -> { order(priority: :desc) }
  scope :active, -> { where(status: [ :pending, :in_progress ]) }
end
