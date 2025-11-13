class Response < ApplicationRecord
  belongs_to :questionnaire
  belongs_to :account
  belongs_to :respondent, class_name: "User"

  has_one :compliance_assessment, dependent: :destroy
  has_one :conversation, dependent: :nullify

  has_many :answers, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :processing_activities, dependent: :nullify
  has_many :waitlist_entries, dependent: :destroy

  enum :status, {
    in_progress: 0,
    completed: 1
  }, prefix: true

  validates :status, presence: true

  before_create :set_started_at
  after_update :generate_processing_activities, if: :saved_change_to_status_to_completed?

  scope :for_account, ->(account) { where(account: account) }
  scope :completed, -> { where(status: :completed) }

  def waitlist_features_needed
    answers.includes(:answer_choice)
      .select { |a| a.answer_choice&.triggers_waitlist? }
      .map { |a| a.answer_choice.waitlist_feature_key }
      .compact
      .uniq
  end

  def requires_waitlist?
    waitlist_features_needed.any?
  end

  private

  def set_started_at
    self.started_at ||= Time.current
  end

  def generate_processing_activities
    ProcessingActivityGenerator.new(self).generate_from_questionnaire
  end

  def saved_change_to_status_to_completed?
    saved_change_to_status? && status_completed?
  end
end
