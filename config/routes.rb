Rails.application.routes.draw do
  resources :messages, only: [:create]
end
