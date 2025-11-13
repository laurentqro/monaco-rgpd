class LogicRule < ApplicationRecord
  belongs_to :source_question, class_name: "Question"
  belongs_to :target_section, class_name: "Section", optional: true
  belongs_to :target_question, class_name: "Question", optional: true

  enum :condition_type, {
    equals: 0,
    not_equals: 1,
    contains: 2,
    greater_than: 3,
    less_than: 4
  }, prefix: true

  enum :action, {
    show: 0,
    hide: 1,
    skip_to_section: 2,
    exit_questionnaire: 3,
    skip_to_question: 4,
    exit_to_waitlist: 5
  }, prefix: true

  validates :condition_type, presence: true
  validates :action, presence: true
end
