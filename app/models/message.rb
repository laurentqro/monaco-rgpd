class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :question, optional: true

  enum :role, {
    user: 0,
    assistant: 1,
    system: 2
  }, prefix: true

  validates :role, presence: true
  validates :content, presence: true

  scope :chronological, -> { order(created_at: :asc) }
  scope :by_user, -> { where(role: :user) }
  scope :by_assistant, -> { where(role: :assistant) }

  def extracted_answers?
    extracted_data.present? && extracted_data['answers'].present?
  end
end
