Rails.application.routes.draw do

  root to: redirect("/#{I18n.default_locale}/articles")

  scope "/:locale" do
    get "/about", to: "about#index", as: :about
    resources :articles
    resources :projects
    devise_for :users
  end
  # Health Check
  get "up" => "rails/health#show", as: :rails_health_check
end
