Rails.application.routes.draw do
  resources :files#, only: [:create, :index]
end
