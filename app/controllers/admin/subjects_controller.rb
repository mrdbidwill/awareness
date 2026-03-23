# frozen_string_literal: true

module Admin
  class SubjectsController < Admin::ApplicationController
    before_action :set_subject, only: %i[show edit update destroy]

    def index
      authorize Subject
      @subjects = policy_scope(Subject)
                    .left_joins(:articles)
                    .select("subjects.*, COUNT(articles.id) AS articles_count")
                    .group("subjects.id")
                    .order(:name)
                    .page(params[:page])
                    .per(20)
    end

    def show
      authorize @subject
    end

    def new
      @subject = Subject.new
      authorize @subject
    end

    def create
      @subject = Subject.new(subject_params)
      authorize @subject

      if @subject.save
        redirect_to admin_subject_path(@subject), notice: "Subject created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @subject
    end

    def update
      authorize @subject

      if @subject.update(subject_params)
        redirect_to admin_subject_path(@subject), notice: "Subject updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @subject
      @subject.destroy!
      redirect_to admin_subjects_path, notice: "Subject deleted."
    end

    private

    def set_subject
      @subject = Subject.find_by!(slug: params[:id])
    rescue ActiveRecord::RecordNotFound
      @subject = Subject.find(params[:id])
    end

    def subject_params
      params.require(:subject).permit(:name, :slug)
    end
  end
end
