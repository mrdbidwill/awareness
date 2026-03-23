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
  before_create :generate_otp_secret
  def generate_otp_secret
    self.otp_secret ||= User.generate_otp_secret
  end

  def otp_provisioning_uri(account = email, issuer: 'Awareness')
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

  # Content and account associations
  has_many :trusted_devices, dependent: :destroy
  has_many :articles, dependent: :nullify
  has_many :newsletter_campaigns, dependent: :destroy

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
