class Account < ApplicationRecord
  belongs_to :owner, class_name: "User", optional: true
  has_many :users, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_one :active_subscription, -> { where(status: "active") }, class_name: "Subscription"
  has_many :compliance_assessments, dependent: :destroy
  has_many :responses, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :processing_activities, dependent: :destroy

  enum :account_type, {
    solopreneur: 0,
    company: 1,
    consultant: 2
  }, prefix: true

  enum :compliance_mode, {
    simple: 0,
    modular: 1
  }, prefix: true

  enum :entity_type, {
    company: 0,
    ngo: 1,
    government: 2,
    association: 3
  }, prefix: true

  enum :legal_form, {
    sarl: 0,      # Société à Responsabilité Limitée
    sam: 1,       # Société Anonyme Monégasque
    snc: 2,       # Société en Nom Collectif
    scs: 3,       # Société en Commandite Simple
    sca: 4,       # Société en Commandite par Actions
    surl: 5,      # Société Unipersonnelle à Responsabilité Limitée
    sima: 6,      # Société d'Innovation Monégasque par Actions
    ei: 7,        # Entreprise Individuelle
    sci: 8        # Société Civile Immobilière
  }, prefix: :legal_form

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: true,
    format: {
      with: /\A[a-z0-9-]+\z/,
      message: "only allows lowercase letters, numbers, and hyphens"
    }
  validates :jurisdiction, presence: true
  validates :account_type, presence: true

  # Set compliance_mode based on account_type
  before_validation :set_compliance_mode, on: :create

  def subscribed?
    active_subscription.present?
  end

  def onboarding_completed?
    onboarding_completed_at.present?
  end

  def complete_for_document_generation?
    name.present? &&
    address.present? &&
    phone.present? &&
    rci_number.present? &&
    legal_form.present?
  end

  def legal_form_full_name
    return nil unless legal_form.present?

    {
      "sarl" => "Société à Responsabilité Limitée (SARL)",
      "sam" => "Société Anonyme Monégasque (SAM)",
      "snc" => "Société en Nom Collectif (SNC)",
      "scs" => "Société en Commandite Simple (SCS)",
      "sca" => "Société en Commandite par Actions (SCA)",
      "surl" => "Société Unipersonnelle à Responsabilité Limitée (SURL)",
      "sima" => "Société d'Innovation Monégasque par Actions (SIMA)",
      "ei" => "Entreprise Individuelle",
      "sci" => "Société Civile Immobilière (SCI)"
    }[legal_form]
  end

  def missing_profile_fields
    fields = []
    fields << :address if address.blank?
    fields << :phone if phone.blank?
    fields << :rci_number if rci_number.blank?
    fields << :legal_form if legal_form.blank?
    fields
  end

  private

  def set_compliance_mode
    self.compliance_mode ||= account_type_solopreneur? ? :simple : :modular
  end
end
