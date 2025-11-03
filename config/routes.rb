Rails.application.routes.draw do
  # Authentication
  resource :session, only: [ :new, :destroy ]
  resources :magic_links, only: [ :create ]
  get "auth/verify/:token", to: "magic_links#verify", as: :verify_magic_link

  # Non authenticated pages
  get "home", to: "pages#home", as: :home
  get "showcase", to: "showcase#index" if Rails.env.development?

  # Authenticated app (authentication handled by ApplicationController)
  get "dashboard", to: "dashboard#show", as: :app_root

  # User management
  resources :users, only: [ :update ]

  # Account management
  resources :accounts, only: [ :update ] do
    member do
      patch :complete_profile
    end
  end

  # Questionnaires and Responses
  resources :questionnaires, only: [ :index, :show ] do
    resources :responses, only: [ :create, :show, :update ]
  end

  resources :responses, only: [ :index ] do
    resources :answers, only: [ :create, :update ]
    member do
      post :complete
      get :results
    end
  end

  # Dashboard
  get "dashboard", to: "dashboard#show"

  # Processing Activities
  resources :processing_activities, path: "registre-traitements", only: [ :index, :show, :new, :create, :edit, :update, :destroy ]

  # Documents
  resources :documents, only: [ :index, :show, :create ] do
    collection do
      post :generate_privacy_policy
    end
  end

  # Settings
  namespace :settings do
    get :profile
    get :account
    get :team
    get :billing
    resource :notifications, only: [ :show, :update ]
  end
  get "settings", to: redirect("/settings/profile")

  # Admin
  namespace :admin do
    resource :session, only: [ :new, :create, :destroy ]
    resources :accounts, only: [ :index, :show, :update, :destroy ]
    resources :users, only: [ :index, :show, :update, :destroy ]
    post "users/:id/impersonate", to: "impersonations#create", as: :impersonate_user
    delete "impersonations", to: "impersonations#destroy", as: :stop_impersonating
    resources :subscriptions, only: [ :index ]
    resources :admins, only: [ :index, :create, :destroy ]
    root "dashboard#index"
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root
  root "pages#home"
end
