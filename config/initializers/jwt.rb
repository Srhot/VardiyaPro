# frozen_string_literal: true

# JWT Configuration
Rails.application.config.jwt_secret = ENV.fetch('JWT_SECRET') do
  raise 'JWT_SECRET environment variable must be set in production' if Rails.env.production?

  # Use Rails secret_key_base in development/test
  Rails.application.secret_key_base
end

Rails.application.config.jwt_expiry = ENV.fetch('JWT_EXPIRY_HOURS', 24).to_i.hours
