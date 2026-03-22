# frozen_string_literal: true

class InvitationMailer < ApplicationMailer
  def invite(invitation_token)
    @invitation_token = invitation_token
    @magic_link = guest_session_url(token: invitation_token.token)
    @expires_at = invitation_token.admin_expires_at

    mail(
      to: invitation_token.email,
      subject: 'Invitation: 24-Hour Admin Access to Awareness'
    )
  end
end
