# frozen_string_literal: true

class DeviseMailer < Devise::Mailer
  # Override devise_mail to ensure mapping is available
  def devise_mail(record, action, opts = {}, &block)
    # Set the resource to make it available to the parent class
    @devise_mapping = Devise.mappings[:user]
    super
  end

  # Use deliver_later for async email delivery
  def confirmation_instructions(record, token, opts = {})
    super
  end

  def reset_password_instructions(record, token, opts = {})
    super
  end

  def unlock_instructions(record, token, opts = {})
    super
  end

  def email_changed(record, opts = {})
    super
  end

  def password_change(record, opts = {})
    super
  end
end
