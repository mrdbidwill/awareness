require "test_helper"

class Admin::NewsletterCampaignsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:three)
    @owner_user = users(:one)
    @regular_user = users(:two)
    @campaign = newsletter_campaigns(:draft)
  end

  test "admin can view index" do
    sign_in @admin_user
    get admin_newsletter_campaigns_path
    assert_response :success
  end

  test "admin can create campaign" do
    sign_in @admin_user

    assert_difference("NewsletterCampaign.count", 1) do
      post admin_newsletter_campaigns_path, params: {
        newsletter_campaign: {
          subject: "Fresh Content",
          body: "Hello newsletter readers."
        }
      }
    end

    assert_redirected_to admin_newsletter_campaign_path(NewsletterCampaign.last)
  end

  test "queue_delivery enqueues dispatch job" do
    sign_in @admin_user
    campaign = NewsletterCampaign.create!(user: @admin_user, subject: "Queue Me", body: "Body")

    assert_enqueued_with(job: NewsletterCampaignDispatchJob) do
      post queue_delivery_admin_newsletter_campaign_path(campaign)
    end

    assert_redirected_to admin_newsletter_campaign_path(campaign)
    assert campaign.reload.queued?
  end

  test "regular user cannot access admin campaigns" do
    sign_in @regular_user
    get admin_newsletter_campaigns_path
    assert_redirected_to root_path
  end

  test "owner can queue campaign created by admin" do
    sign_in @owner_user
    campaign = NewsletterCampaign.create!(user: @admin_user, subject: "Owner Queue", body: "Body")

    post queue_delivery_admin_newsletter_campaign_path(campaign)
    assert_redirected_to admin_newsletter_campaign_path(campaign)
    assert campaign.reload.queued?
  end
end
