class Conversation < ApplicationRecord
  belongs_to :response, optional: true
  belongs_to :questionnaire
  belongs_to :account
  has_many :messages, dependent: :destroy

  enum :status, {
    in_progress: 0,
    completed: 1,
    abandoned: 2
  }, prefix: true

  validates :status, presence: true
  validates :started_at, presence: true

  scope :active, -> { where(status: :in_progress) }
  scope :recent, -> { order(started_at: :desc) }

  def duration
    return nil unless started_at && completed_at
    completed_at - started_at
  end

  def message_count
    messages.count
  end
end
