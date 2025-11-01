source "https://rubygems.org"

ruby "3.3.5"

gem "rails", "~> 8.0.0"
gem "pg", "~> 1.6"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "mini_racer", platforms: :ruby
gem "redis", ">= 4.0.1"
gem "tzinfo-data", platforms: %i[windows jruby]
gem "bootsnap", require: false
gem "image_processing", "~> 1.13"

group :development, :test do
  gem "debug", platforms: %i[mri windows]

  gem "rspec-rails"
  gem "rspec_junit_formatter", require: false

  gem "brakeman"
  gem "dotenv-rails", "~> 3.1"
  gem "rubocop", "~> 1.23"
  gem "rubocop-performance"
  gem "rubocop-rails"

  gem "pry"
  gem "pry-remote"
end

group :development do
  gem "foreman"
  gem "web-console"
  gem "letter_opener"

  gem "solargraph"
  gem "solargraph-rails"
  gem "ruby-lsp"
  gem "ruby-lsp-rails"
end

group :test do
  # ⬇️ Nodig voor de fout "uninitialized constant Shoulda"
  gem "shoulda-matchers", "~> 6.1"
  gem "spree_dev_tools"
  gem "rails-controller-testing"
  # optioneel handig
  gem "database_cleaner-active_record", "~> 2.0"
end

gem "sidekiq"
gem "devise"
gem "sentry-ruby"
gem "sentry-rails"
gem "sentry-sidekiq"

# Spree
spree_opts = "~> 5.1"
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
