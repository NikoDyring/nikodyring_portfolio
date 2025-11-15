Rails.application.routes.draw do
  # Keep your global root
  root to: redirect("/#{I18n.default_locale}/articles")

  scope "/:locale" do
    get "/about", to: "about#index", as: :about
    resources :articles, controller: "articles"
    resources :projects, controller: "projects"
    devise_for :users
  end

  get "up", to: "rails/health#show", as: :rails_health_check
end
