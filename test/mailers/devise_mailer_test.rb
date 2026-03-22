require "test_helper"

class DeviseMailerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "password reset email can be sent" do
    # Use Devise's actual mechanism which properly sets up mappings
    assert_emails 1 do
      @user.send_reset_password_instructions
    end

    # Verify the email was delivered
    email = ActionMailer::Base.deliveries.last
    assert_equal [@user.email], email.to
    assert_match /password/i, email.subject
  end

  test "password change notification can be sent" do
    # Trigger actual Devise flow
    assert_emails 1 do
      @user.send(:send_password_change_notification)
    end

    email = ActionMailer::Base.deliveries.last
    assert_equal [@user.email], email.to
    assert_match /password.*change/i, email.subject
  end

  test "email change notification can be sent" do
    old_email = @user.email

    assert_emails 1 do
      @user.skip_reconfirmation!
      @user.update(email: "newemail@example.com")
      @user.send(:send_email_changed_notification)
    end

    email = ActionMailer::Base.deliveries.last
    # Devise sends email changed notification to the OLD email for security
    assert_equal [old_email], email.to
    assert_match /email.*change/i, email.subject
  end
end
