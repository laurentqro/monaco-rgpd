class Section < ApplicationRecord
  belongs_to :questionnaire
  has_many :questions, dependent: :destroy
  has_many :logic_rules, foreign_key: :target_section_id, dependent: :destroy

  validates :title, presence: true
  validates :order_index, presence: true, numericality: { only_integer: true }

  default_scope { order(order_index: :asc) }
end
