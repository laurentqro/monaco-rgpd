Rails.application.routes.draw do
  # Authentication
  resource :session, only: [:new, :destroy]
  resources :magic_links, only: [:create]
  get "auth/verify/:token", to: "magic_links#verify", as: :verify_magic_link

  # Authenticated app (authentication handled by ApplicationController)
  get "app", to: "app#index", as: :app_root

  # User management
  resources :users, only: [:update]

  # Account management
  resources :accounts, only: [:update]

  # Questionnaires and Responses
  resources :questionnaires, only: [:show] do
    resources :responses, only: [:create, :show, :update]
  end

  resources :responses, only: [:index] do
    resources :answers, only: [:create, :update]
    member do
      post :complete
      get :results
    end
  end

  # Dashboard
  get "dashboard", to: "dashboard#show"

  # Settings
  namespace :settings do
    get :profile
    get :account
    get :team
    get :billing
    resource :notifications, only: [:show, :update]
  end
  get "settings", to: redirect("/settings/profile")

  # Admin
  namespace :admin do
    resource :session, only: [:new, :create, :destroy]
    resources :accounts, only: [:index, :show, :update, :destroy]
    resources :users, only: [:index, :show, :update, :destroy]
    post "users/:id/impersonate", to: "impersonations#create", as: :impersonate_user
    delete "impersonations", to: "impersonations#destroy", as: :stop_impersonating
    resources :subscriptions, only: [:index]
    resources :admins, only: [:index, :create, :destroy]
    root "dashboard#index"
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root
  root "sessions#new"
end
