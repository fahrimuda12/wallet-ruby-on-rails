Rails.application.routes.draw do
  # resources :wallet do
  #   collection do
  #     post 'simpan'
  #   end
  # end


  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    resources :transactions, only: [:create]
  end

  # wallet route
  # namespace :wallet do
  #   resources :transactions, only: [:create]
  # end
  get "wallets" => "wallet#index"
  get "wallets/:id" => "wallet#show"
  post "wallets/save" => "wallet#create"
  put "wallets/:id" => "wallet#update"

  # Defines the root path route ("/")
  # root "posts#index"
end
