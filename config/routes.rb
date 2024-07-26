Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    root to: "fields#index"
    resources :fields
  end
end
