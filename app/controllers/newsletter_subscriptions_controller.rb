class NewsletterSubscriptionsController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  skip_after_action :verify_authorized, raise: false
  skip_after_action :verify_policy_scoped, raise: false

  def new
    @subscriber = NewsletterSubscriber.new
  end

  def create
    email = newsletter_subscription_params[:email].to_s.strip.downcase
    @subscriber = NewsletterSubscriber.find_or_initialize_by(email: email)

    if @subscriber.subscribed?
      redirect_to new_newsletter_path, notice: "This email is already subscribed."
      return
    end

    @subscriber.status = :pending
    @subscriber.confirmation_sent_at = Time.current
    @subscriber.confirmed_at = nil

    if @subscriber.save
      NewsletterMailer.confirmation_email(@subscriber.id).deliver_later
      redirect_to new_newsletter_path, notice: "Please check your email to confirm your subscription."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def confirm
    subscriber = NewsletterSubscriber.find_signed!(
      params[:token],
      purpose: :newsletter_confirm
    )

    if subscriber.subscribed?
      redirect_to articles_path, notice: "Your newsletter subscription is already confirmed."
      return
    end

    subscriber.confirm_subscription!
    redirect_to articles_path, notice: "Subscription confirmed. Welcome to the newsletter."
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
    redirect_to new_newsletter_path, alert: "That confirmation link is invalid or expired."
  end

  def unsubscribe
    subscriber = NewsletterSubscriber.find_signed!(
      params[:token],
      purpose: :newsletter_unsubscribe
    )

    if subscriber.unsubscribed?
      redirect_to articles_path, notice: "You are already unsubscribed."
      return
    end

    subscriber.unsubscribe!
    redirect_to articles_path, notice: "You have been unsubscribed from newsletter emails."
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
    redirect_to new_newsletter_path, alert: "That unsubscribe link is invalid."
  end

  private

  def newsletter_subscription_params
    params.require(:newsletter_subscription).permit(:email)
  end
end
