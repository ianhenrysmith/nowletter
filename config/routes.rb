Rails.application.routes.draw do
  resources :subscription_messages, only: [:create]
  resources :newsletter_messages, only: [:create]

  match "render_homepage", to: "pages#index", via: [:get]
end
