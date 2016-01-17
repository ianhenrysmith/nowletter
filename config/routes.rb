Rails.application.routes.draw do
  resources :subscription_messages, only: [:create]
  resources :newsletter_messages, only: [:create]

  match "render_homepage", to: "pages#index", via: [:get]

  root "pages#home"

  get '*bad_route', to: "pages#not_found"
end
