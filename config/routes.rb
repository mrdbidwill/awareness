Rails.application.routes.draw do
  # Auto-Glossary routes
  mount AutoGlossary::Engine => "/glossary"
  # Mycowriter routes
  mount Mycowriter::Engine => "/mycowriter"
  get "mushroom_search/index"
  get "mushroom_search/autocomplete_characters", to: "mushroom_search#autocomplete_characters", defaults: { format: :json }
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    passwords: 'users/passwords'
  }

  resources :direct_uploads, only: [:create]

  # Two-Factor Authentication routes
  namespace :users do
    resource :two_factor_settings, only: [] do
      post :enable
      post :verify
      delete :disable
    end
  end

  # 2FA login verification
  resource :user_two_factor_authentication, only: [:show, :update], controller: 'users/two_factor_authentication'

  # Mushrooms and related nested relationships
  resources :mushrooms do
    resources :image_mushrooms, only: [:new, :create, :edit, :update, :destroy]
    resources :mushroom_species, only: [:index, :new, :create, :destroy]
    resources :genus_mushrooms, only: [:index, :new, :create, :destroy]
    resources :comparisons, controller: 'mushroom_comparisons', only: [:index, :create], as: 'mushroom_comparisons'
    member do
      get 'edit_characters', to: 'mushrooms#edit_characters', as: :edit_characters
      post 'clone_characters', to: 'mushrooms#clone_characters', as: :clone_characters
    end
    resource :core_character_entry, only: [:show]
  end

  # Standalone comparison show route (not nested under mushroom)
  resources :mushroom_comparisons, only: [:show]

  # Generic resources
  resources :all_groups
  resources :all_group_mushrooms
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
  resources :clusters
  resources :cluster_mushrooms
  resources :mr_character_mushrooms, only: [:create] do
    collection do
      post :bulk_update
    end
  end
  resources :mushroom_trees, except: [:destroy]
  resources :mushroom_plants, except: [:destroy]
  resources :mushroom_projects
  resources :mushroom_species, except: [:destroy]
  resources :projects
  resources :genus_mushrooms, except: [:destroy]
  resources :states, only: [:index] # main use is for states in the dropdown

  # Expose public ImageMushrooms index/show to match controller
  resources :image_mushrooms


  # Guest session magic link route
  resource :guest_session, only: [:create]

  # Admin-specific routes
  namespace :admin do
    root to: "dashboard#index"
    get 'database/export', to: 'database_exports#export', as: :database_export
    resources :core_character_sequences, only: [:index] do
      collection do
        patch :update
      end
    end
    resources :admin_todos
    resources :invitations, only: [:index, :new, :create, :destroy]
    resources :articles
    resources :newsletter_campaigns do
      post :queue_delivery, on: :member
    end
    resources :colors
    resources :countries
    resources :display_options
    resources :dna_sequences
    resources :fungus_types
    resources :genera
    resources :image_mushrooms
    resources :lenses
    resources :lookup_items
    resources :lookup_tables
    resources :observation_methods
    resources :mb_lists
    resources :mr_characters
    resource  :mr_characters_source, only: :show
    resources :parts
    resources :permissions
    resources :plants
    resources :projects  # Universal projects managed by admins
    resources :roles
    resources :source_data do
      member do
        get :versions
      end
    end
    resources :source_data_types
    resources :storage_locations
    resources :species
    resources :states
    resources :trees
    resources :users, controller: "/users"
    resources :lookup_items do
      member do
        get :versions
      end
    end
    resources :mr_characters do
      member do
        get :versions
      end
    end
  end

  get  "/contact", to: "contacts#new"
  post "/contact", to: "contacts#create"

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # Static pages
  authenticated :user do
    root to: 'pages#home', as: :authenticated_root
  end
  root 'pages#home'
  get 'trees_of_blakeley_signs', to: 'pages#trees_of_blakeley_signs'
  get 'terms', to: 'pages#terms'

  # iNaturalist data routes
  get 'inaturalist/observation_fields', to: 'inaturalist_data#index', as: :inaturalist_observation_fields
  get 'inaturalist/observation_fields/download/csv', to: 'inaturalist_data#download_csv', as: :download_inaturalist_csv
  get 'inaturalist/observation_fields/download/json', to: 'inaturalist_data#download_json', as: :download_inaturalist_json

  # Health check
  get 'up' => 'rails/health#show', as: :rails_health_check
  get 'health' => 'rails/health#show', as: :health_check

  # Autocomplete routes
  get "autocomplete/genera",        to: "autocomplete#genera",        as: :genera_autocomplete, defaults: { format: :json }
  get "autocomplete/species",       to: "autocomplete#species",       as: :species_autocomplete, defaults: { format: :json }
  get "autocomplete/trees",         to: "autocomplete#trees",         as: :trees_autocomplete, defaults: { format: :json }
  get "autocomplete/plants",        to: "autocomplete#plants",        as: :plants_autocomplete, defaults: { format: :json }
  get "autocomplete/mr_characters", to: "autocomplete#mr_characters", as: :mr_characters_autocomplete, defaults: { format: :json }

  resources :genus_mushrooms, only: [:create], defaults: { format: :json } do
    delete :destroy_by_relation, on: :collection, defaults: { format: :json }
  end
  resources :mushroom_species, only: [:create], defaults: { format: :json } do
    delete :destroy_by_relation, on: :collection, defaults: { format: :json }
  end
  resources :mushroom_trees, only: [:create], defaults: { format: :json } do
    delete :destroy_by_relation, on: :collection, defaults: { format: :json }
  end
  resources :mushroom_plants, only: [:create], defaults: { format: :json } do
    delete :destroy_by_relation, on: :collection, defaults: { format: :json }
  end
end
