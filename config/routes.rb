# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root 'home#index'

  get 'search', to: 'search#index', as: :search
  resource :cart, only: :show
  resource :checkout, only: %i[show create]
  resources :cart_items, only: %i[create update destroy], param: :product_id
  resources :orders, only: %i[index show] do
    resource :payment, only: :create
  end
  resources :products, only: :show
  resources :categories, only: :show, param: :slug
  get 'payments/success', to: 'payments#success', as: :payment_success

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check
end
