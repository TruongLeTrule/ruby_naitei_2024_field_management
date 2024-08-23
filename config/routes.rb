require "sidekiq/web"
require "sidekiq-scheduler/web"
require "sidekiq-status/web"

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"
  devise_for :users, only: :omniauth_callbacks, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  scope "(:locale)", locale: /en|vi/ do
    root to: "fields#index"
    devise_for :users, skip: :omniauth_callbacks,
               controllers: {confirmations: "confirmations"}
    get "/booking_history", to: "booking_history#index"
    resources :fields do
      member do
        get :order, to: "fields#new_order"
        post :order, to: "fields#create_order"
        resources :unavailable_field_schedules, only: :index
      end
    end
    resources :users do
      member do
        post :active, to: "users#update_active"
      end
    end
    resources :ratings, only: %i(create update destroy) do
      member do
        resources :reviews, except: %i(show index)
      end
    end
    resources :vouchers, only: :apply do
      member do
        post "apply"
      end
    end
    namespace :admin do
      root to: "fields#index"
      resources :fields, except: :show do
        resources :unavailable_field_schedules
      end
    end
    resources :account_activations, only: :edit
    resources :password_resets, except: %i(index show destroy)
    resources :orders do
      collection do
        get :export
        get :export_status
        get :export_download
      end
    end
    resources :favourites, only: %i(create destroy)
    resources :activities
  end
end
