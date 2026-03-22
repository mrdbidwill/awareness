class ContactMailer < ApplicationMailer
  def contact_message(name:, email:, subject:, message:, recipient:)
    @name = name
    @email = email
    @subject = subject
    @message = message

    mail(
      to: recipient,
      reply_to: email,
      subject: subject
    )
  end
end