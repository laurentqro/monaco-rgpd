class WaitlistEntry < ApplicationRecord
  belongs_to :response, optional: true

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :features_needed, presence: true

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
end
