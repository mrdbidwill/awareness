require "test_helper"

class ContactMailerTest < ActionMailer::TestCase
  test "contact_message delivers email with correct attributes" do
    email = ContactMailer.contact_message(
      name: "Test User",
      email: "test@example.com",
      subject: "Test Subject",
      message: "This is a test message",
      recipient: "admin@example.com"
    )

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["admin@example.com"], email.to
    assert_equal ["test@example.com"], email.reply_to
    assert_equal "Test Subject", email.subject
  end

  test "contact_message includes sender name and email in body" do
    email = ContactMailer.contact_message(
      name: "John Doe",
      email: "john@example.com",
      subject: "Inquiry",
      message: "I have a question",
      recipient: "support@example.com"
    )

    assert_match "John Doe", email.body.encoded
    assert_match "john@example.com", email.body.encoded
  end

  test "contact_message includes the message content" do
    message_content = "This is my detailed question about mushrooms"
    email = ContactMailer.contact_message(
      name: "Jane Smith",
      email: "jane@example.com",
      subject: "Question",
      message: message_content,
      recipient: "info@example.com"
    )

    assert_match message_content, email.body.encoded
  end

  test "contact_message handles special characters in name and message" do
    email = ContactMailer.contact_message(
      name: "José García",
      email: "jose@example.com",
      subject: "Special chars: <>&",
      message: "Message with special chars: <script>alert('xss')</script>",
      recipient: "admin@example.com"
    )

    assert_not_nil email
    assert_equal "Special chars: <>&", email.subject
  end
end
