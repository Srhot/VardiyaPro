# frozen_string_literal: true

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

      # Set current user and request for audit logging
      def set_audit_context(record)
        record.current_user_for_audit = current_user if record.respond_to?(:current_user_for_audit=)
        record.current_request_for_audit = request if record.respond_to?(:current_request_for_audit=)
      end
    end
  end
end
