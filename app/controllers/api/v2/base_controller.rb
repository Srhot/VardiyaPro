# frozen_string_literal: true

module Api
  module V2
    class BaseController < Api::V1::BaseController
      # API v2 Base Controller
      # Inherits all functionality from v1 and adds v2-specific features

      before_action :set_api_version

      private

      def set_api_version
        response.headers['X-API-Version'] = 'v2'
      end

      # Override to add v2-specific error handling if needed
      def user_not_authorized
        render json: {
          errors: ['You are not authorized to perform this action'],
          api_version: 'v2'
        }, status: :forbidden
      end
    end
  end
end
