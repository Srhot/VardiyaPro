module Api
  module V1
    class BaseController < ApplicationController
      include Authenticable

      # Common API v1 functionality
      # - Authentication via Authenticable concern (authenticate_request before_action)
      # - Error handling
      # - Response formatting

      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity

      private

      def not_found(exception)
        render json: { errors: [exception.message] }, status: :not_found
      end

      def unprocessable_entity(exception)
        render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end
