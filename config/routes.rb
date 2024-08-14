Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    root to: "fields#index"
    devise_for :users
    get "/unavailable_field_schedules", to: "unavailable_field_schedules#index"
    post "/apply_voucher", to: "vouchers#apply"
    get "/booking_history", to: "booking_history#index"
    resources :fields do
      member do
        get :order, to: "fields#new_order"
        post :order, to: "fields#create_order"
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
    resources :account_activations, only: :edit
    resources :password_resets, except: %i(index show destroy)
    resources :orders
    resources :favourites, only: %i(create destroy)
    resources :activities
  end
end
