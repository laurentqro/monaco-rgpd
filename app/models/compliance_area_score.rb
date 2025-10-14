class ComplianceAreaScore < ApplicationRecord
  belongs_to :compliance_assessment
  belongs_to :compliance_area

  validates :score, presence: true
  validates :max_score, presence: true

  def percentage
    (score / max_score * 100).round(1)
  end
end
