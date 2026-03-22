require "test_helper"

class NewsletterCampaignTest < ActiveSupport::TestCase
  setup do
    @campaign = newsletter_campaigns(:draft)
  end

  test "enqueue_delivery queues campaign from draft" do
    assert_enqueued_with(job: NewsletterCampaignDispatchJob) do
      assert @campaign.enqueue_delivery!
    end

    @campaign.reload
    assert @campaign.queued?
  end

  test "enqueue_delivery rejects non-draft campaigns" do
    sent = newsletter_campaigns(:sent)
    assert_not sent.enqueue_delivery!
  end

  test "track_delivery_result marks sent when complete" do
    @campaign.update!(status: :sending, recipients_count: 1, delivered_count: 0, failed_count: 0)
    @campaign.track_delivery_result!(success: true)

    @campaign.reload
    assert_equal 1, @campaign.delivered_count
    assert @campaign.sent?
    assert_not_nil @campaign.sent_at
  end
end
