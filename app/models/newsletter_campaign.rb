class NewsletterCampaign < ApplicationRecord
  belongs_to :user

  enum :status, { draft: 0, queued: 1, sending: 2, sent: 3, failed: 4 }, default: :draft

  validates :subject, :body, presence: true

  scope :recent, -> { order(created_at: :desc) }

  def enqueue_delivery!
    return false unless draft?

    update!(
      status: :queued,
      queued_at: Time.current,
      recipients_count: NewsletterSubscriber.deliverable.count,
      delivered_count: 0,
      failed_count: 0,
      started_at: nil,
      sent_at: nil,
      last_error: nil
    )

    NewsletterCampaignDispatchJob.perform_later(id)
    true
  end

  def track_delivery_result!(success:, error: nil)
    with_lock do
      self.delivered_count += 1 if success
      unless success
        self.failed_count += 1
        self.last_error = error.to_s.truncate(250) if error.present?
      end

      complete = recipients_count.zero? || (delivered_count + failed_count) >= recipients_count
      if complete
        self.status = :sent
        self.sent_at ||= Time.current
      elsif queued?
        self.status = :sending
      end

      save!
    end
  end
end
