Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions",
    passwords: "users/passwords"
  }

  resources :direct_uploads, only: [:create]

  namespace :users do
    resource :two_factor_settings, only: [] do
      post :enable
      post :verify
      delete :disable
    end
  end

  resource :user_two_factor_authentication, only: [:show, :update], controller: "users/two_factor_authentication"

  resources :articles, only: %i[index show] do
    collection do
      get :archive
      get "archive/:year", action: :archive, as: :archive_year, constraints: { year: /\d{4}/ }
      get "archive/:year/:month", action: :archive, as: :archive_month, constraints: { year: /\d{4}/, month: /\d{1,2}/ }
      get "subject/:subject_slug", action: :archive, as: :subject
    end
  end
  resources :books, only: [:index]
  resource :newsletter_subscription, only: %i[new create], path: "newsletter", as: :newsletter do
    get :confirm, on: :collection
    get :unsubscribe, on: :collection
  end

  # Stand-alone engines shared across projects
  mount AutoGlossary::Engine => "/glossary"
  mount Mycowriter::Engine => "/mycowriter"
  get "autocomplete/genera", to: "autocomplete#genera", as: :genera_autocomplete, defaults: { format: :json }
  get "autocomplete/species", to: "autocomplete#species", as: :species_autocomplete, defaults: { format: :json }

  namespace :admin do
    root to: "dashboard#index"
    resources :articles
    resources :subjects
    resources :sources
    resources :newsletter_campaigns do
      post :queue_delivery, on: :member
    end
    resources :users, controller: "/users"
  end

  get "/contact", to: "contacts#new"
  post "/contact", to: "contacts#create"

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  authenticated :user do
    root to: "pages#home", as: :authenticated_root
  end
  root "pages#home"
  get "terms", to: "pages#terms"

  get "up" => "rails/health#show", as: :rails_health_check
  get "health" => "rails/health#show", as: :health_check
end
