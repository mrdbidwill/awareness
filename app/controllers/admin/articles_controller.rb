# frozen_string_literal: true

module Admin
  class ArticlesController < Admin::ApplicationController
    before_action :set_article, only: %i[show edit update destroy]

    # GET /admin/articles
    def index
      authorize Article
      @articles = policy_scope(Article)
                    .includes(:subject)
                    .order(published: :desc, published_at: :desc, created_at: :desc)
                    .page(params[:page])
                    .per(20)
    end

    # GET /admin/articles/:id
    def show
      authorize @article
    end

    # GET /admin/articles/new
    def new
      @article = Article.new
      authorize @article
    end

    # POST /admin/articles
    def create
      @article = Article.new(article_params)
      @article.user = current_user
      @subject_assist_name = subject_assist_param
      apply_subject_assist_to_article!(persist: params[:preview].blank?)
      authorize @article

      if params[:preview].present?
        @article.valid?
        prepare_preview
        render :preview, status: :ok
      else
        if @article.save
          redirect_to admin_article_path(@article), notice: "Article created."
        else
          render :new, status: :unprocessable_entity
        end
      end
    end

    # GET /admin/articles/:id/edit
    def edit
      authorize @article
    end

    # PATCH/PUT /admin/articles/:id
    def update
      authorize @article
      @article.assign_attributes(article_params)
      @subject_assist_name = subject_assist_param
      apply_subject_assist_to_article!(persist: params[:preview].blank?)

      if params[:preview].present?
        @article.valid?
        prepare_preview
        render :preview, status: :ok
      else
        if @article.save
          redirect_to admin_article_path(@article), notice: "Article updated."
        else
          render :edit, status: :unprocessable_entity
        end
      end
    end

    # DELETE /admin/articles/:id
    def destroy
      authorize @article
      @article.destroy
      redirect_to admin_articles_path, notice: "Article deleted."
    end

    private

    def set_article
      # Prefer slug, fallback to id
      @article = Article.includes(:subject).find_by!(slug: params[:id])
    rescue ActiveRecord::RecordNotFound
      @article = Article.includes(:subject).find(params[:id])
    end

    def article_params
      params.require(:article).permit(
        :title,
        :slug,
        :subject_id,
        :summary,
        :body,
        :published,
        :published_at
      )
    end

    def prepare_preview
      @preview_subject = Subject.find_by(id: @article.subject_id)
      @preview_subject ||= Subject.new(name: @subject_assist_name) if @subject_assist_name.present?
    end

    def apply_subject_assist_to_article!(persist:)
      return if @article.subject_id.present?
      return if @subject_assist_name.blank?

      subject = Subject.where("LOWER(name) = ?", @subject_assist_name.downcase).first
      if subject.nil? && persist
        subject = Subject.new(name: @subject_assist_name)
        unless subject.save
          @article.errors.add(:subject, subject.errors.full_messages.to_sentence)
          return
        end
      end

      @article.subject_id = subject.id if subject.present?
    end

    def subject_assist_param
      params.dig(:article, :subject_assist).to_s.strip
    end
  end
end
