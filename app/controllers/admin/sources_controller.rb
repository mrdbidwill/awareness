# frozen_string_literal: true

module Admin
  class SourcesController < Admin::ApplicationController
    before_action :set_source, only: %i[show edit update destroy]

    def index
      authorize Source
      @sources = policy_scope(Source).recent_first.page(params[:page]).per(20)
    end

    def show
      authorize @source
    end

    def new
      @source = Source.new
      authorize @source
    end

    def create
      @source = Source.new(source_params)
      authorize @source

      if @source.save
        redirect_to admin_source_path(@source), notice: "Source created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @source
    end

    def update
      authorize @source

      if @source.update(source_params)
        redirect_to admin_source_path(@source), notice: "Source updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @source
      @source.destroy!
      redirect_to admin_sources_path, notice: "Source deleted."
    end

    private

    def set_source
      @source = Source.find(params[:id])
    end

    def source_params
      params.require(:source).permit(:name, :author, :description, :publish_year)
    end
  end
end
