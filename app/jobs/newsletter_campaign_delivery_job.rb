class NewsletterCampaignDeliveryJob < ApplicationJob
  queue_as :mailers

  def perform(campaign_id, subscriber_id)
    campaign = NewsletterCampaign.find_by(id: campaign_id)
    subscriber = NewsletterSubscriber.find_by(id: subscriber_id)
    return if campaign.blank? || subscriber.blank?
    return unless subscriber.subscribed? && subscriber.confirmed_at.present?

    NewsletterMailer.campaign_email(campaign.id, subscriber.id).deliver_now
    subscriber.update_column(:last_emailed_at, Time.current)
    campaign.track_delivery_result!(success: true)
  rescue StandardError => e
    campaign&.track_delivery_result!(success: false, error: e.message)
    Rails.logger.error("[NewsletterCampaignDeliveryJob] campaign=#{campaign_id} subscriber=#{subscriber_id} error=#{e.class}: #{e.message}")
  end
end
