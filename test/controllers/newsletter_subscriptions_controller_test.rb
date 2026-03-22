require "test_helper"

class NewsletterSubscriptionsControllerTest < ActionDispatch::IntegrationTest
  test "should get signup page" do
    get new_newsletter_path
    assert_response :success
  end

  test "creates pending subscription and enqueues confirmation email" do
    assert_difference("NewsletterSubscriber.count", 1) do
      assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
        post newsletter_path, params: { newsletter_subscription: { email: "new-subscriber@example.com" } }
      end
    end

    assert_redirected_to new_newsletter_path
    subscriber = NewsletterSubscriber.find_by!(email: "new-subscriber@example.com")
    assert subscriber.pending?
    assert_not_nil subscriber.confirmation_sent_at
  end

  test "confirm subscribes pending subscriber" do
    subscriber = newsletter_subscribers(:pending)
    get confirm_newsletter_path(token: subscriber.confirmation_token)

    assert_redirected_to articles_path
    assert subscriber.reload.subscribed?
  end

  test "unsubscribe marks subscriber unsubscribed" do
    subscriber = newsletter_subscribers(:subscribed)
    get unsubscribe_newsletter_path(token: subscriber.unsubscribe_token)

    assert_redirected_to articles_path
    assert subscriber.reload.unsubscribed?
  end

  test "confirm handles invalid token" do
    get confirm_newsletter_path(token: "bad-token")
    assert_redirected_to new_newsletter_path
  end
end
