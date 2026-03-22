require "test_helper"

class ContactsControllerTest < ActionDispatch::IntegrationTest
  test "should get new without authentication" do
    get contact_url
    assert_response :success
  end

  test "should create contact message with valid params" do
    assert_emails 1 do
      post contact_url, params: {
        name: "Test User",
        email: "test@example.com",
        subject: "Test Subject",
        message: "Test message content",
        recipient: "contact@mrdbid.com"
      }
    end

    assert_redirected_to contact_path
    assert_equal "Thanks! Your message has been sent.", flash[:notice]
  end

  test "should reject submission with honeypot filled" do
    assert_no_emails do
      post contact_url, params: {
        name: "Bot",
        email: "bot@example.com",
        subject: "Spam",
        message: "Spam content",
        website_url: "http://spam.com"  # Honeypot field
      }
    end

    assert_redirected_to contact_path
    assert_equal "Thanks! Your message has been sent.", flash[:notice]
  end

  test "should reject submission with missing required fields" do
    assert_no_emails do
      post contact_url, params: {
        name: "",
        email: "test@example.com",
        subject: "Test",
        message: "Message"
      }
    end

    assert_redirected_to contact_path
    assert_match /Please provide/, flash[:alert]
  end

  test "should use default recipient for invalid recipient" do
    assert_emails 1 do
      post contact_url, params: {
        name: "Test User",
        email: "test@example.com",
        subject: "Test Subject",
        message: "Test message",
        recipient: "invalid@example.com"  # Not in allowed list
      }
    end

    assert_redirected_to contact_path
  end

  test "should allow all valid recipients" do
    valid_recipients = ['contact@mrdbid.com', 'webmaster@mrdbid.com', 'will@mrdbid.com']

    valid_recipients.each do |recipient|
      assert_emails 1 do
        post contact_url, params: {
          name: "Test User",
          email: "test@example.com",
          subject: "Test Subject",
          message: "Test message",
          recipient: recipient
        }
      end
    end
  end

  # Skipping: test requires mocha which is not configured
  # test "should handle mailer errors gracefully" do
  #   ContactMailer.stubs(:contact_message).raises(StandardError.new("Mail error"))
  #
  #   post contacts_url, params: {
  #     name: "Test User",
  #     email: "test@example.com",
  #     subject: "Test Subject",
  #     message: "Test message"
  #   }
  #
  #   assert_redirected_to contact_path
  #   assert_match /could not send/, flash[:alert]
  # end
end
