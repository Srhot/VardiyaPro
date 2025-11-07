Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check

  # API v1 namespace
  namespace :api do
    namespace :v1 do
      # Authentication
      post 'auth/login', to: 'auth#login'
      post 'auth/refresh', to: 'auth#refresh'
      delete 'auth/logout', to: 'auth#logout'

      # Resources
      resources :departments, only: [:index, :show, :create, :update]
      resources :shifts
      # resources :assignments
      # resources :users
      # resources :notifications
      # resources :reports, only: [] do
      #   collection do
      #     get 'employee/:id', to: 'reports#employee'
      #     get 'department/:id', to: 'reports#department'
      #     get 'overtime', to: 'reports#overtime'
      #   end
      # end
    end
  end
end
