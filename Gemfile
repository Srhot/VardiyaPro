source "https://rubygems.org"

ruby "3.3.9"

# Rails
gem "rails", "~> 8.1.0"

# Database
gem "pg", "~> 1.6"

# Web server
gem "puma", "~> 6.4"

# Authentication
gem "bcrypt", "~> 3.1.20"
gem "jwt", "~> 3.1.2"

# CORS
gem "rack-cors"

# Solid Stack (Rails 8)
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Pagination
gem "kaminari", "~> 1.2"

# Authorization
gem "pundit", "~> 2.4"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  # N+1 query detection
  gem "bullet"

  # Testing
  gem "rspec-rails", "~> 7.0"
  gem "factory_bot_rails"
  gem "faker"
end

group :test do
  gem "simplecov", require: false
  gem "database_cleaner-active_record"
end
