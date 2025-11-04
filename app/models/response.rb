class Response < ApplicationRecord
  belongs_to :questionnaire
  belongs_to :account
  belongs_to :respondent, class_name: "User"

  has_one :compliance_assessment, dependent: :destroy
  has_one :conversation, dependent: :nullify

  has_many :answers, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :processing_activities, dependent: :nullify

  enum :status, {
    in_progress: 0,
    completed: 1
  }, prefix: true

  validates :status, presence: true

  before_create :set_started_at

  scope :for_account, ->(account) { where(account: account) }
  scope :completed, -> { where(status: :completed) }

  private

  def set_started_at
    self.started_at ||= Time.current
  end
end
