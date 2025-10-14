class AnswerChoice < ApplicationRecord
  belongs_to :question

  validates :choice_text, presence: true
  validates :order_index, presence: true, numericality: { only_integer: true }

  default_scope { order(order_index: :asc) }
end
