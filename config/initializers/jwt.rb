# JWT Configuration
Rails.application.config.jwt_secret = ENV.fetch('JWT_SECRET') do
  if Rails.env.production?
    raise "JWT_SECRET environment variable must be set in production"
  else
    # Use Rails secret_key_base in development/test
    Rails.application.secret_key_base
  end
end

Rails.application.config.jwt_expiry = ENV.fetch('JWT_EXPIRY_HOURS') { 24 }.to_i.hours
