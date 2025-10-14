class ProcessingActivity < ApplicationRecord
  belongs_to :account
  belongs_to :response, optional: true

  has_many :processing_purposes, dependent: :destroy
  has_many :data_category_details, dependent: :destroy
  has_many :access_categories, dependent: :destroy
  has_many :recipient_categories, dependent: :destroy

  # Sensitive data justifications
  enum :sensitive_data_justification, {
    explicit_consent: 0,
    vital_interests: 1,
    religious_organization_members: 2,
    manifestly_public_data: 3,
    legal_claims: 4,
    public_interest: 5,
    medical_purposes: 6,
    archiving_research_statistical: 7,
    biometric_workplace_access: 8,
    employment_social_security: 9,
    statistics_institute: 10,
    administrative_judicial_authority: 11,
    public_health_interest: 12
  }, prefix: true

  # Transfer safeguards (Art. 94)
  enum :transfer_safeguard, {
    international_commitment: 0,
    standard_clauses: 1,
    binding_corporate_rules: 2,
    certification: 3,
    code_of_conduct: 4,
    none: 5
  }, prefix: true

  # Transfer derogations (Art. 95)
  enum :transfer_derogation, {
    explicit_consent: 0,
    vital_interests: 1,
    public_interest: 2,
    legal_claims: 3,
    public_register: 4,
    contract_execution: 5,
    third_party_contract: 6,
    none: 7
  }, prefix: true

  validates :name, presence: true

  accepts_nested_attributes_for :processing_purposes, allow_destroy: true
  accepts_nested_attributes_for :data_category_details, allow_destroy: true
  accepts_nested_attributes_for :access_categories, allow_destroy: true
  accepts_nested_attributes_for :recipient_categories, allow_destroy: true
end
