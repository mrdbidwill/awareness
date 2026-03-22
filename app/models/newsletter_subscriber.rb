class NewsletterSubscriber < ApplicationRecord
  enum :status, { pending: 0, subscribed: 1, unsubscribed: 2 }, default: :pending

  before_validation :normalize_email

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :deliverable, -> { subscribed.where.not(confirmed_at: nil) }

  def confirmation_token
    signed_id(purpose: :newsletter_confirm, expires_in: 2.days)
  end

  def unsubscribe_token
    signed_id(purpose: :newsletter_unsubscribe)
  end

  def mark_pending!
    update!(
      status: :pending,
      confirmation_sent_at: Time.current,
      confirmed_at: nil
    )
  end

  def confirm_subscription!
    update!(
      status: :subscribed,
      confirmed_at: Time.current,
      unsubscribed_at: nil
    )
  end

  def unsubscribe!
    update!(
      status: :unsubscribed,
      unsubscribed_at: Time.current
    )
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
