class DataCategoryDetail < ApplicationRecord
  belongs_to :processing_activity

  enum :category_type, {
    identity_family: 0,
    contact_info: 1,
    education_professional: 2,
    financial: 3,
    official_documents: 4,
    lifestyle_consumption: 5,
    electronic_id: 6,
    criminal_records: 7,
    temporal_info: 8,
    location_data: 9,
    biometric_genetic: 10
  }, prefix: true

  enum :retention_period_enum, {
    one_month: 0,
    two_months: 1,
    three_months: 2,
    six_months: 3,
    one_year: 4,
    two_years: 5,
    three_years: 6,
    five_years: 7,
    ten_years: 8,
    other: 9
  }, prefix: true

  validates :category_type, presence: true
end
