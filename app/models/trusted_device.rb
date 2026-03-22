# app/models/trusted_device.rb
class TrustedDevice < ApplicationRecord
  belongs_to :user

  validates :device_token, presence: true, uniqueness: true
  validates :device_fingerprint, presence: true
  validates :trusted_at, presence: true
  validates :expires_at, presence: true

  before_validation :set_timestamps, on: :create
  before_validation :generate_token, on: :create

  scope :active, -> { where('expires_at > ?', Time.current) }
  scope :expired, -> { where('expires_at <= ?', Time.current) }

  def self.cleanup_expired
    expired.delete_all
  end

  def expired?
    expires_at <= Time.current
  end

  def active?
    !expired?
  end

  private

  def set_timestamps
    self.trusted_at ||= Time.current
    self.expires_at ||= 30.days.from_now
  end

  def generate_token
    self.device_token ||= SecureRandom.urlsafe_base64(32)
  end
end
