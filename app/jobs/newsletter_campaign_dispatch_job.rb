class NewsletterCampaignDispatchJob < ApplicationJob
  queue_as :mailers

  def perform(campaign_id)
    campaign = NewsletterCampaign.find(campaign_id)
    return unless campaign.queued?

    subscriber_ids = NewsletterSubscriber.deliverable.pluck(:id)

    campaign.update!(
      status: :sending,
      started_at: Time.current,
      recipients_count: subscriber_ids.length
    )

    if subscriber_ids.empty?
      campaign.update!(status: :sent, sent_at: Time.current)
      return
    end

    subscriber_ids.each do |subscriber_id|
      NewsletterCampaignDeliveryJob.perform_later(campaign.id, subscriber_id)
    end
  rescue StandardError => e
    campaign&.update(status: :failed, last_error: e.message.to_s.truncate(250))
    raise
  end
end
