Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    root to: "fields#index"
    get "/signup", to: "users#new"
    post "/signup", to: "users#create"
    resources :fields
    resources :users
    resources :account_activations, only: :edit
  end
end
