class ComplianceAssessment < ApplicationRecord
  belongs_to :response
  belongs_to :account
  has_many :compliance_area_scores, dependent: :destroy
  has_many :compliance_areas, through: :compliance_area_scores
  has_many :action_items, as: :actionable, dependent: :destroy

  enum :status, {
    draft: 0,
    completed: 1
  }, prefix: true

  validates :overall_score, presence: true
  validates :max_possible_score, presence: true

  before_save :calculate_risk_level

  scope :for_account, ->(account) { where(account: account) }
  scope :completed, -> { where(status: :completed) }

  private

  def calculate_risk_level
    percentage = (overall_score / max_possible_score * 100).round

    self.risk_level = case percentage
    when 85..100 then "compliant"
    when 60..84 then "attention_required"
    else "non_compliant"
    end
  end
end
