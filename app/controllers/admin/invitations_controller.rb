# frozen_string_literal: true

class Admin::InvitationsController < Admin::ApplicationController
  skip_after_action :verify_policy_scoped, only: :index, raise: false

  def index
    @invitation_tokens = InvitationToken.order(created_at: :desc).page(params[:page])
    authorize InvitationToken
  end

  def new
    @invitation_token = InvitationToken.new
    authorize @invitation_token
  end

  def create
    @invitation_token = InvitationToken.new(invitation_params)
    @invitation_token.created_by = current_user
    authorize @invitation_token

    if @invitation_token.save
      # Send invitation email
      InvitationMailer.invite(@invitation_token).deliver_later

      redirect_to admin_invitations_path, notice: "Invitation sent to #{@invitation_token.email}"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @invitation_token = InvitationToken.find(params[:id])
    authorize @invitation_token

    @invitation_token.destroy
    redirect_to admin_invitations_path, notice: 'Invitation deleted'
  end

  private

  def invitation_params
    params.require(:invitation_token).permit(:email)
  end
end
