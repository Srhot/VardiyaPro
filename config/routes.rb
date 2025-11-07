Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check

  # API v1 namespace
  namespace :api do
    namespace :v1 do
      # Authentication
      namespace :auth do
        post 'login', to: 'auth#login'
        post 'refresh', to: 'auth#refresh'
        delete 'logout', to: 'auth#logout'
      end

      # Resources will be added here as we build the API
      # resources :shifts
      # resources :assignments
      # resources :users
      # resources :departments
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
