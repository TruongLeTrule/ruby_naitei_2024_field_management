Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    root to: "fields#index"
    get "/signup", to: "users#new"
    post "/signup", to: "users#create"
    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"
    get "/unavailable_field_schedules", to: "unavailable_field_schedules#index"
    resources :fields do
      member do
        get :order, to: "fields#new_order"
        post :order, to: "fields#create_order"
      end
    end
    resources :users
    resources :account_activations, only: :edit
    resources :orders
  end
end
