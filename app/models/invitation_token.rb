# frozen_string_literal: true

class InvitationToken < ApplicationRecord
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_user_id'
  belongs_to :invited_user, class_name: 'User', optional: true

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, presence: true, uniqueness: true
  validates :admin_expires_at, presence: true

  before_validation :generate_token, on: :create
  before_validation :set_expiration, on: :create

  scope :unused, -> { where(used_at: nil) }
  scope :used, -> { where.not(used_at: nil) }
  scope :expired, -> { where('admin_expires_at < ?', Time.current) }
  scope :active, -> { unused.where('admin_expires_at > ?', Time.current) }

  def used?
    used_at.present?
  end

  def expired?
    admin_expires_at < Time.current
  end

  def mark_as_used!(user)
    update!(used_at: Time.current, invited_user: user)
  end

  private

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(32)
  end

  def set_expiration
    # Token link expires in 7 days, but admin access is 24 hours from first login
    self.admin_expires_at ||= 24.hours.from_now
  end
end
