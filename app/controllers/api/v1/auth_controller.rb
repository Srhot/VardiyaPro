# frozen_string_literal: true

module Api
  module V1
    class AuthController < BaseController
      skip_before_action :authenticate_request, only: [:login], if: :has_authenticable?

      # POST /api/v1/auth/login
      def login
        user = User.find_by(email: params[:email]&.downcase)

        if user&.authenticate(params[:password])
          if user.active?
            token = JsonWebToken.encode(user_id: user.id)
            render json: {
              token: token,
              user: user_response(user)
            }, status: :ok
          else
            render json: { errors: ['Account is not active'] }, status: :unauthorized
          end
        else
          render json: { errors: ['Invalid email or password'] }, status: :unauthorized
        end
      end

      # POST /api/v1/auth/refresh
      def refresh
        token = JsonWebToken.encode(user_id: current_user.id)
        render json: {
          data: { token: token }
        }, status: :ok
      end

      # DELETE /api/v1/auth/logout
      def logout
        # JWT is stateless, so logout is handled client-side by removing token
        # Could implement token blacklist here if needed
        render json: { message: 'Logged out successfully' }, status: :ok
      end

      private

      def user_response(user)
        {
          id: user.id,
          email: user.email,
          name: user.name,
          role: user.role,
          department_id: user.department_id,
          active: user.active
        }
      end

      def has_authenticable?
        self.class.ancestors.include?(Authenticable)
      end
    end
  end
end
