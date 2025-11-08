# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Health check endpoint
  get 'up' => 'rails/health#show', as: :rails_health_check

  # API v1 namespace
  namespace :api do
    namespace :v1 do
      # Authentication
      post 'auth/login', to: 'auth#login'
      post 'auth/refresh', to: 'auth#refresh'
      delete 'auth/logout', to: 'auth#logout'

      # Resources
      resources :departments, only: %i[index show create update]
      resources :shifts
      resources :assignments do
        member do
          patch :confirm
          patch :complete
          patch :cancel
        end
      end

      resources :users do
        member do
          post :activate
          post :deactivate
          patch :update_password
        end
      end

      resources :notifications, only: %i[index show destroy] do
        collection do
          patch :mark_all_as_read
          delete :destroy_all_read
        end
        member do
          patch :mark_as_read
        end
      end

      # Reports
      get 'reports/employee/:id', to: 'reports#employee'
      get 'reports/department/:id', to: 'reports#department'
      get 'reports/overtime', to: 'reports#overtime'
      get 'reports/summary', to: 'reports#summary'

      # Audit Logs (admin only)
      resources :audit_logs, only: %i[index show] do
        collection do
          get :for_record
        end
      end
    end

    # API v2 namespace (New version with additional features)
    namespace :v2 do
      # Authentication (same as v1)
      post 'auth/login', to: 'auth#login'

      # Users (enhanced with additional fields)
      resources :users, only: %i[index show create update] do
        member do
          get :profile # NEW: Enhanced profile with more details
          get :statistics # NEW: User statistics
        end
      end

      # Departments (enhanced with team metrics)
      resources :departments, only: %i[index show create update] do
        member do
          get :team_metrics # NEW: Team performance metrics
        end
      end

      # Shifts (enhanced with capacity planning)
      resources :shifts do
        collection do
          get :capacity_report # NEW: Capacity planning report
        end
      end
    end
  end
end
