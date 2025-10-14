class Question < ApplicationRecord
  belongs_to :section
  has_many :answer_choices, dependent: :destroy
  has_many :logic_rules, foreign_key: :source_question_id, dependent: :destroy
  has_many :answers, dependent: :destroy

  enum :question_type, {
    single_choice: 0,
    multiple_choice: 1,
    text_short: 2,
    text_long: 3,
    yes_no: 4,
    rating_scale: 5
  }, prefix: true

  validates :question_text, presence: true
  validates :question_type, presence: true
  validates :order_index, presence: true, numericality: { only_integer: true }

  default_scope { order(order_index: :asc) }
end
