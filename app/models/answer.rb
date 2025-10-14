class Answer < ApplicationRecord
  belongs_to :response
  belongs_to :question

  validates :answer_value, presence: true
  validates :question_id, uniqueness: { scope: :response_id }

  # Calculate score based on question type and answer
  after_save :calculate_score

  private

  def calculate_score
    return unless question.weight.present?

    # Score calculation logic will be implemented based on question type
    # For now, store as-is
  end
end
