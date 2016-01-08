Rails.application.routes.draw do
  resources :messages, only: [:create]

  match "render_homepage", to: "pages#index", via: [:get]
end
