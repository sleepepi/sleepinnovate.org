# frozen_string_literal: true

# rubocop:disable Layout/ExtraSpacing
source "https://rubygems.org"

gem "rails",                      "6.1.6"

# PostgreSQL as the Active Record database.
gem "pg",                         "1.2.3"

# Gems used by project.
gem "autoprefixer-rails"
gem "bootstrap",                  "~> 4.6.0"
gem "carrierwave",                "~> 2.2.2"
gem "devise",                     "~> 4.8.0"
gem "figaro",                     "~> 1.2.0"
gem "font-awesome-sass",          "~> 5.15.1"
gem "haml",                       "~> 5.2.2"
gem "kaminari",                   "~> 1.2.1"
gem "mini_magick",                "~> 4.11.0"
gem "net-imap",                   require: false
gem "net-pop",                    require: false
gem "net-smtp",                   require: false
gem "redcarpet",                  "~> 3.5.1"
gem "sitemap_generator",          "~> 6.0.2"

# Rails defaults.
gem "coffee-rails",               "~> 5.0"
gem "sass-rails",                 ">= 6"
gem "uglifier",                   ">= 1.3.0"

gem "jbuilder",                   "~> 2.9"
gem "jquery-rails",               "~> 4.4.0"
gem "turbolinks",                 "~> 5"

group :development do
  gem "listen",                   "~> 3.3"
  gem "spring"
  gem "spring-watcher-listen",    "~> 2.0.0"
  gem "web-console",              ">= 4.1.0"
end

group :test do
  gem "artifice"
  gem "artifice-passthru"
  gem "capybara",                 ">= 3.26"
  gem "minitest"
  gem "puma"
  gem "rails-controller-testing"
  gem "selenium-webdriver"
  gem "simplecov",                "~> 0.16.1", require: false
end
# rubocop:enable Layout/ExtraSpacing
