# frozen_string_literal: true

module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request
  end

  private

  def authenticate_request
    @current_user = authorize_request
    render json: { errors: ['Unauthorized'] }, status: :unauthorized unless @current_user
  end

  def authorize_request
    header = request.headers['Authorization']
    return nil unless header

    token = header.split.last
    decoded = JsonWebToken.decode(token)
    return nil unless decoded

    User.find_by(id: decoded[:user_id])
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def current_user
    @current_user
  end

  # Skip authentication for specific actions
  def skip_authentication
    skip_before_action :authenticate_request
  end
end
