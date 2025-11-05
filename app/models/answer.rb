class Answer < ApplicationRecord
  belongs_to :response
  belongs_to :question
  belongs_to :answer_choice, optional: true

  validates :question_id, uniqueness: { scope: :response_id }
  validate :exactly_one_answer_field_present

  after_save :calculate_score

  def answer_choice_text
    answer_choice&.choice_text
  end

  def answer_text_value
    answer_text
  end

  def answer_numeric_value
    answer_number || answer_rating
  end

  private

  def calculate_score
    return nil unless question.weight.present?
    # Score calculation logic will be implemented based on question type
  end

  def exactly_one_answer_field_present
    fields = [
      answer_choice_id,
      answer_text,
      answer_rating,
      answer_number,
      answer_date
    ].compact

    has_boolean = !answer_boolean.nil?

    total_fields = fields.count + (has_boolean ? 1 : 0)

    if total_fields == 0
      errors.add(:base, "At least one answer field must be present")
    elsif total_fields > 1
      errors.add(:base, "Only one answer field can be set")
    end
  end
end
