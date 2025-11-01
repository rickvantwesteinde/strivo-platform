source "https://rubygems.org"

ruby '3.3.5'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 8.0.0'

# Use pg as the database for Active Record
gem "pg", "~> 1.6"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Mini Racer for JavaScript runtime (required for asset precompilation)
gem 'mini_racer', platforms: :ruby

# Use Redis adapter to run Action Cable in production
gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis
# gem "kredis"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants
gem "image_processing", "~> 1.13"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ]

  gem "rspec-rails"
  gem "rspec_junit_formatter", require: false

  gem 'brakeman'
  gem 'dotenv-rails', '~> 3.1'
  gem 'rubocop', '~> 1.23'
  gem 'rubocop-performance'
  gem 'rubocop-rails'

  # monitoring
  gem 'pry'
  gem 'pry-remote'
end

group :development do
  gem "foreman"
  gem "web-console"
  gem "letter_opener"

  # LSP support for Ruby
  gem 'solargraph'
  gem 'solargraph-rails'
  gem 'ruby-lsp'
  gem 'ruby-lsp-rails'

  # gem "rack-mini-profiler"
  # gem "spring"
end

group :test do
  gem 'spree_dev_tools'
  gem 'rails-controller-testing'

  # === Toegevoegd om je test stack te fixen ===
  gem 'shoulda-matchers', '~> 6.4', require: false
  gem 'factory_bot_rails', '~> 6.4'
  gem 'capybara', '>= 3.39'
  gem 'selenium-webdriver', '>= 4.20'
  gem 'webdrivers', require: false
end

# Use Sidekiq for background jobs
gem 'sidekiq'

# Use Devise for authentication
gem "devise"

# Sentry for error/performance monitoring
gem 'sentry-ruby'
gem 'sentry-rails'
gem 'sentry-sidekiq'

# Spree gems
spree_opts = '~> 5.1'
gem "spree", spree_opts
gem "spree_emails", spree_opts
gem "spree_sample", spree_opts
gem "spree_admin", spree_opts
gem "spree_storefront", spree_opts
gem "spree_i18n"
gem "spree_stripe"
gem "spree_google_analytics", "~> 1.0"
gem "spree_klaviyo", "~> 1.0"
gem "spree_paypal_checkout", "~> 0.5"

gem "strivo_admin", path: "engines/strivo_admin"
