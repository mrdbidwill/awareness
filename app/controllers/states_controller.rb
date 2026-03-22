class StatesController < ApplicationController
  skip_before_action :authenticate_user!, only: :index, raise: false
  skip_before_action :verify_authenticity_token, only: :index, raise: false
  skip_after_action :verify_policy_scoped, only: :index, raise: false

  def index
    states = State.where(country_id: params[:country_id]).order(:name).select(:id, :name)
    respond_to do |format|
      format.json { render json: states }
      format.html { head :not_found }
    end
  end
end