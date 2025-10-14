class MagicLink < ApplicationRecord
  belongs_to :user

  validates :user, presence: true
  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  def generate_token
    self.token = SecureRandom.urlsafe_base64(32)
    self.expires_at = 15.minutes.from_now
  end

  def expired?
    expires_at < Time.current
  end

  def used?
    used_at.present?
  end

  def valid_for_use?
    !expired? && !used?
  end

  def mark_as_used!
    update!(used_at: Time.current)
  end
end
