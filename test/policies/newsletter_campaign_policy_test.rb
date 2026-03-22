require "test_helper"

class NewsletterCampaignPolicyTest < ActiveSupport::TestCase
  setup do
    @owner_user = users(:one)
    @admin_user = users(:three)
    @regular_user = users(:two)
    @campaign_by_admin = NewsletterCampaign.new(user: @admin_user, subject: "Campaign", body: "Body", status: :draft)
    @campaign_by_owner = NewsletterCampaign.new(user: @owner_user, subject: "Owner Campaign", body: "Body", status: :draft)
    @sent_campaign = NewsletterCampaign.new(user: @admin_user, subject: "Sent", body: "Body", status: :sent)
  end

  test "admins can index and create" do
    assert Pundit.policy(@admin_user, NewsletterCampaign).index?
    assert Pundit.policy(@owner_user, NewsletterCampaign).create?
  end

  test "regular user cannot access campaigns" do
    assert_not Pundit.policy(@regular_user, NewsletterCampaign).index?
    assert_not Pundit.policy(@regular_user, @campaign_by_admin).show?
  end

  test "owner can manage any campaign" do
    assert Pundit.policy(@owner_user, @campaign_by_admin).show?
    assert Pundit.policy(@owner_user, @campaign_by_admin).update?
    assert Pundit.policy(@owner_user, @campaign_by_admin).queue_delivery?
  end

  test "admin can manage only own campaign" do
    assert Pundit.policy(@admin_user, @campaign_by_admin).update?
    assert_not Pundit.policy(@admin_user, @campaign_by_owner).update?
  end

  test "cannot edit or queue sent campaigns" do
    assert_not Pundit.policy(@admin_user, @sent_campaign).update?
    assert_not Pundit.policy(@admin_user, @sent_campaign).queue_delivery?
  end
end
