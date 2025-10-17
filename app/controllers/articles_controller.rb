class ArticlesController < ApplicationController
  def index
    params[:category] ||= "coding"
    @articles = Article.where(category: params[:category]).order(created_at: :desc)
  end
end
