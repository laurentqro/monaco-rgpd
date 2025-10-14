class ComplianceArea < ApplicationRecord
  has_many :compliance_area_scores, dependent: :destroy

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
end
