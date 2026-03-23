# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM", "contact@awareness.example.com")
  layout "mailer"

  # Use deliver_later by default for async email delivery
  self.delivery_job = ActionMailer::MailDeliveryJob
end
