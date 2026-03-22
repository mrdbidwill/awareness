require "test_helper"

class NewsletterSubscriberTest < ActiveSupport::TestCase
  test "normalizes email before validation" do
    subscriber = NewsletterSubscriber.new(email: "  TEST@Example.com  ")
    subscriber.valid?

    assert_equal "test@example.com", subscriber.email
  end

  test "requires valid email format" do
    subscriber = NewsletterSubscriber.new(email: "invalid")
    assert_not subscriber.valid?
  end

  test "builds confirmation and unsubscribe tokens" do
    subscriber = newsletter_subscribers(:pending)

    assert subscriber.confirmation_token.present?
    assert subscriber.unsubscribe_token.present?
  end

  test "confirm_subscription marks subscribed" do
    subscriber = newsletter_subscribers(:pending)
    subscriber.confirm_subscription!

    assert subscriber.subscribed?
    assert_not_nil subscriber.confirmed_at
    assert_nil subscriber.unsubscribed_at
  end

  test "unsubscribe marks unsubscribed" do
    subscriber = newsletter_subscribers(:subscribed)
    subscriber.unsubscribe!

    assert subscriber.unsubscribed?
    assert_not_nil subscriber.unsubscribed_at
  end
end
