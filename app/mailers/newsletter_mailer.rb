class NewsletterMailer < ApplicationMailer
  def confirmation_email(subscriber_id)
    @subscriber = NewsletterSubscriber.find(subscriber_id)
    @confirm_url = confirm_newsletter_url(token: @subscriber.confirmation_token)
    @unsubscribe_url = unsubscribe_newsletter_url(token: @subscriber.unsubscribe_token)

    mail(
      to: @subscriber.email,
      subject: "Confirm your Awareness newsletter subscription"
    )
  end

  def campaign_email(campaign_id, subscriber_id)
    @campaign = NewsletterCampaign.find(campaign_id)
    @subscriber = NewsletterSubscriber.find(subscriber_id)
    @unsubscribe_url = unsubscribe_newsletter_url(token: @subscriber.unsubscribe_token)

    mail(
      to: @subscriber.email,
      from: @campaign.from_email.presence || ENV.fetch("MAILER_FROM", "contact@awareness.example.com"),
      subject: @campaign.subject
    )
  end
end
