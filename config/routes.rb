Rails.application.routes.draw do
  # resources :wallet do
  #   collection do
  #     post 'simpan'
  #   end
  # end


  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # get "up" => "rails/health#show", as: :rails_health_check

  # namespace :api do
  #   resources :transactions, only: [:create]
  # end

  # wallet route
  # namespace :wallet do
  #   resources :transactions, only: [:create]
  # end
  

  # namespace :wallet do
  #   get "" => "wallet#index"
  #   get ":id" => "wallet#show"
  #   post "save" => "wallet#create"
  #   put ":id" => "wallet#update"
  # end

  post 'login', to: 'sessions#login'
  post 'register', to: 'sessions#register'

  resources :wallet, only: [:index, :show, :create, :update, :destroy], controller: 'wallet', path_names: { create: 'create' }
  resources :transactions, only: [:create, :index]

  # namespace :api do
  #   resources :wallets, only: [:create] do
  #     member do
  #       post :validate_key_phrases
  #     end
  #   end
  # end

  # Defines the root path route ("/")
  # root "posts#index"
end
