module Api
  module V1
    class BaseController < ApplicationController
      include Authenticable
      include Pundit::Authorization

      # Common API v1 functionality
      # - Authentication via Authenticable concern (authenticate_request before_action)
      # - Authorization via Pundit
      # - Error handling
      # - Response formatting

      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

      private

      def not_found(exception)
        render json: { errors: [exception.message] }, status: :not_found
      end

      def unprocessable_entity(exception)
        render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
      end

      def user_not_authorized
        render json: { errors: ['You are not authorized to perform this action'] }, status: :forbidden
      end
    end
  end
end
