class Questionnaire < ApplicationRecord
  has_many :sections, dependent: :destroy
  has_many :questions, through: :sections
  has_many :responses, dependent: :destroy

  enum :status, {
    draft: 0,
    published: 1,
    archived: 2
  }, prefix: true

  validates :title, presence: true
  validates :status, presence: true

  scope :published, -> { where(status: :published) }
end
