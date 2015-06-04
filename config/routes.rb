Rails.application.routes.draw do
  resources :zones
  root 'zones#index'
end
