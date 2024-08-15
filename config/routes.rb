Rails.application.routes.draw do
  devise_for :users, only: :omniauth_callbacks, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  scope "(:locale)", locale: /en|vi/ do
    root to: "fields#index"
    devise_for :users, skip: :omniauth_callbacks,
               controllers: {confirmations: "confirmations"}
    post "/apply_voucher", to: "vouchers#apply"
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
    resources :ratings do
      member do
        resources :reviews, except: %i(show index)
      end
    end
    namespace :admin do
      root to: "fields#index"
      resources :fields, param: :id, except: :show do
        member do
          resources :unavailable_field_schedules, param: :schedule_id
        end
      end
    end
    resources :account_activations, only: :edit
    resources :password_resets, except: %i(index show destroy)
    resources :orders
    resources :favourites, only: %i(create destroy)
    resources :activities
  end
end
