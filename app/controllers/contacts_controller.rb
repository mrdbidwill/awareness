# File: app/controllers/contacts_controller.rb
class ContactsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized, raise: false

  def new
  end

  def create
    # Honeypot check - reject if the hidden field is filled
    if params[:website_url].present?
      Rails.logger.warn("Honeypot triggered: website_url filled - possible spam")
      flash[:notice] = "Thanks! Your message has been sent."
      return redirect_to contact_path
    end

    name = params[:name].to_s.strip
    email = params[:email].to_s.strip
    subject = params[:subject].to_s.strip
    message = params[:message].to_s
    recipient = params[:recipient].to_s.strip

    if name.blank? || email.blank? || subject.blank? || message.blank?
      flash[:alert] = "Please provide your name, email, subject, and a message."
      return redirect_to contact_path
    end

    # Validate recipient is one of the allowed addresses
    allowed_recipients = ENV.fetch("CONTACT_RECIPIENTS", "contact@awareness.example.com,webmaster@awareness.example.com")
                            .split(",")
                            .map(&:strip)
                            .reject(&:blank?)
    default_recipient = allowed_recipients.first || "contact@awareness.example.com"
    recipient = default_recipient unless allowed_recipients.include?(recipient)

    begin
      ContactMailer.contact_message(
        name: name,
        email: email,
        subject: subject,
        message: message,
        recipient: recipient
      ).deliver_now
      flash[:notice] = "Thanks! Your message has been sent."
    rescue => e
      Rails.logger.error("Contact mail failed: #{e.class} - #{e.message}")
      flash[:alert] = "Sorry, we could not send your message. Please try again later."
    end

    redirect_to contact_path
  end
end
