class WaitlistEntry < ApplicationRecord
  belongs_to :response, optional: true

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :features_needed, presence: true
  validate :features_are_valid
  validate :email_feature_uniqueness

  before_validation :normalize_email

  # Scopes for future use
  scope :unnotified, -> { where(notified: false) }
  scope :for_feature, ->(feature_key) { where("features_needed @> ?", [ feature_key ].to_json) }

  # Feature key constants
  FEATURE_KEYS = {
    geographic_expansion: "geographic_expansion",
    association: "association",
    organisme_public: "organisme_public",
    profession_liberale: "profession_liberale",
    video_surveillance: "video_surveillance"
  }.freeze

  private

  def normalize_email
    self.email = email.to_s.downcase.strip if email.present?
  end

  def features_are_valid
    return if features_needed.blank?

    invalid_features = features_needed - FEATURE_KEYS.values
    if invalid_features.any?
      errors.add(:features_needed, "contient des fonctionnalités invalides: #{invalid_features.join(', ')}")
    end
  end

  def email_feature_uniqueness
    return if email.blank? || features_needed.blank?

    features_needed.each do |feature|
      if WaitlistEntry.where.not(id: id)
                      .for_feature(feature)
                      .where("LOWER(email) = ?", email.downcase)
                      .exists?
        errors.add(:email, "déjà inscrit pour #{feature}")
        break
      end
    end
  end
end
