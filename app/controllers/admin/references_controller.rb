# frozen_string_literal: true

module Admin
  class ReferencesController < Admin::ApplicationController
    before_action :set_reference, only: %i[show edit update destroy]

    def index
      authorize Reference
      @references = policy_scope(Reference).recent_first.page(params[:page]).per(20)
    end

    def show
      authorize @reference
    end

    def new
      @reference = Reference.new
      authorize @reference
    end

    def create
      @reference = Reference.new(reference_params)
      authorize @reference

      if @reference.save
        redirect_to admin_reference_path(@reference), notice: "Reference created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @reference
    end

    def update
      authorize @reference

      if @reference.update(reference_params)
        redirect_to admin_reference_path(@reference), notice: "Reference updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @reference
      @reference.destroy!
      redirect_to admin_references_path, notice: "Reference deleted."
    end

    private

    def set_reference
      @reference = Reference.find(params[:id])
    end

    def reference_params
      params.require(:reference).permit(:name, :author, :description, :publish_date)
    end
  end
end
