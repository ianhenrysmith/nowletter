Rails.application.routes.draw do
  resources :subscription_messages, only: [:create]
  resources :newsletter_messages, only: [:create]

  root "pages#index"

  get '*bad_route', to: "pages#not_found"
end
