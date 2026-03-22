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
      authorize @article

      if params[:preview].present?
        @article.valid?
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

      if params[:preview].present?
        @article.valid?
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
  end
end
