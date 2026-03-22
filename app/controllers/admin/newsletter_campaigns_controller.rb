# frozen_string_literal: true

module Admin
  class NewsletterCampaignsController < Admin::ApplicationController
    before_action :set_campaign, only: %i[show edit update destroy queue_delivery]

    def index
      authorize NewsletterCampaign
      @campaigns = policy_scope(NewsletterCampaign).recent.page(params[:page]).per(20)
    end

    def show
      authorize @campaign
    end

    def new
      @campaign = NewsletterCampaign.new
      authorize @campaign
    end

    def create
      @campaign = NewsletterCampaign.new(campaign_params)
      @campaign.user = current_user
      authorize @campaign

      if @campaign.save
        redirect_to admin_newsletter_campaign_path(@campaign), notice: "Campaign created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @campaign
    end

    def update
      authorize @campaign

      if @campaign.update(campaign_params)
        redirect_to admin_newsletter_campaign_path(@campaign), notice: "Campaign updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @campaign
      @campaign.destroy!
      redirect_to admin_newsletter_campaigns_path, notice: "Campaign deleted."
    end

    def queue_delivery
      authorize @campaign

      if @campaign.enqueue_delivery!
        redirect_to admin_newsletter_campaign_path(@campaign), notice: "Campaign queued for delivery."
      else
        redirect_to admin_newsletter_campaign_path(@campaign), alert: "Only draft campaigns can be queued."
      end
    end

    private

    def set_campaign
      @campaign = NewsletterCampaign.find(params[:id])
    end

    def campaign_params
      params.require(:newsletter_campaign).permit(:subject, :body, :from_email)
    end
  end
end
