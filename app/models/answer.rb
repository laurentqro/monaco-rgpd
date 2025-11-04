class Answer < ApplicationRecord
  belongs_to :response
  belongs_to :question

  validates :answer_value, presence: true
  validates :question_id, uniqueness: { scope: :response_id }

  # Calculate score based on question type and answer
  after_save :calculate_score

  def answer_choice_text
    # Look up choice from JSONB answer_value
    choice_id = answer_value["choice_id"] || answer_value[:choice_id]
    return nil unless choice_id

    AnswerChoice.find_by(id: choice_id)&.choice_text
  end

  private

  def calculate_score
    nil unless question.weight.present?

    # Score calculation logic will be implemented based on question type
    # For now, store as-is
  end
end
