# frozen_string_literal: true

class User < ApplicationRecord
  belongs_to :permission, optional: true

  # Honeypot field for spam prevention (not stored in database)
  attr_accessor :website_url

  # Add default Devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable, and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :validatable, :confirmable, :lockable, :two_factor_authenticatable


  # Add the OTP encryption key
  devise :two_factor_authenticatable,
         otp_secret_encryption_key: ENV['OTP_SECRET_ENCRYPTION_KEY']

  # Optional: For backup codes
  devise :two_factor_backupable, otp_number_of_backup_codes: 10

  # Add methods to generate OTP secret and provisioning URI
  # Skip OTP generation for temporary admins
  before_create :generate_otp_secret, unless: :temporary_admin?
  def generate_otp_secret
    self.otp_secret ||= User.generate_otp_secret
  end

  def otp_provisioning_uri(account = email, issuer: 'MRDBID')
    otp_secret.present? ? "otpauth://totp/#{issuer}:#{account}?secret=#{otp_secret}&issuer=#{issuer}" : nil
  end

  def otp_backup_codes
    value = super
    value.is_a?(Array) ? value : []
  end

  def otp_backup_codes=(codes)
    super(Array(codes))
  end

  # Override to generate shorter, user-friendly backup codes
  def generate_otp_backup_codes!
    codes = []
    10.times do
      # Generate 8-character codes: 4 chars + dash + 4 chars (e.g., "a3k9-m2p7")
      code = "#{SecureRandom.alphanumeric(4).downcase}-#{SecureRandom.alphanumeric(4).downcase}"
      codes << code
    end

    # Hash and store the codes
    self.otp_backup_codes = codes.map { |code| Devise::Encryptor.digest(self.class, code) }

    # Return plain text codes for display to user
    codes
  end

  def admin?
    permission_id.present? && permission_id < 5  # Owner-1, Admin-2, Expert-3, Scholar-4, Author-5, Editor-6, Contributor-7, Developer-8, Member-9
  end

  # Elevated admin = full admin privileges (Owner/Admin only)
  def elevated_admin?
    permission_id.present? && permission_id <= 2
  end

  def owner?
    permission_id.present? && permission_id == 1  # Owner-1
  end

  def temporary_admin?
    temporary_admin == true
  end

  def admin_expired?
    temporary_admin? && admin_expires_at.present? && admin_expires_at < Time.current
  end

  def check_and_downgrade_expired_admin!
    return unless admin_expired?

    # Downgrade to Member (permission_id = 9)
    update_columns(
      permission_id: 9,
      temporary_admin: false,
      admin_expires_at: nil
    )
    true
  end

  def time_until_expiration
    return nil unless temporary_admin? && admin_expires_at.present?

    seconds = (admin_expires_at - Time.current).to_i
    return nil if seconds <= 0

    hours = seconds / 3600
    minutes = (seconds % 3600) / 60

    if hours > 0
      "#{hours}h #{minutes}m"
    else
      "#{minutes}m"
    end
  end

  # Association with mushrooms
  has_many :mushrooms, dependent: :destroy
  has_many :all_groups, dependent: :destroy
  has_many :clusters, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_many :trusted_devices, dependent: :destroy
  has_many :articles, dependent: :nullify
  has_many :newsletter_campaigns, dependent: :destroy
  has_many :source_data, class_name: 'SourceData', dependent: :nullify

  # Invitation associations
  has_many :created_invitations, class_name: 'InvitationToken', foreign_key: 'created_by_user_id', dependent: :destroy
  has_one :invitation_token, foreign_key: 'invited_user_id'

  # Default location preferences
  belongs_to :default_country, class_name: 'Country', optional: true
  belongs_to :default_state, class_name: 'State', optional: true

  validates :default_city, length: { maximum: 255 }
  validates :default_county, length: { maximum: 255 }

  # Trusted device methods
  def trust_device!(fingerprint)
    # Remove any existing trusted device for this fingerprint
    trusted_devices.where(device_fingerprint: fingerprint).destroy_all

    # Create new trusted device
    trusted_devices.create!(device_fingerprint: fingerprint)
  end

  def device_trusted?(device_token, fingerprint)
    trusted_devices.active.exists?(
      device_token: device_token,
      device_fingerprint: fingerprint
    )
  end

end
