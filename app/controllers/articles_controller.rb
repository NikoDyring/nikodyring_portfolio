class ArticlesController < ApplicationController
  def index
    params[:category] ||= "coding"
    @articles = Article.where(category: params[:category]).published.order(published_at: :desc)

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("article_list", partial: "articles/article_list", locals: { articles: @articles, current_category: params[:category] })
      end
    end
  end
end
