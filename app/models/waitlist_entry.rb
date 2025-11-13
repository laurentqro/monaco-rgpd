class WaitlistEntry < ApplicationRecord
  belongs_to :response, optional: true

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :features_needed, presence: true

  # Scopes for future use
  scope :unnotified, -> { where(notified: false) }
  scope :for_feature, ->(feature_key) { where("features_needed @> ?", [ feature_key ].to_json) }
end
