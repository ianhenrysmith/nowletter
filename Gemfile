source "https://rubygems.org"

gem "rails", "4.2.5"

gem "pg"

gem "twilio-ruby"

gem "sidekiq"

group :production do
  gem "unicorn"
end

gem "sass-rails", "~> 5.0"
gem "uglifier", ">= 1.3.0"
gem "coffee-rails", "~> 4.1.0"
gem "jquery-rails"
gem "turbolinks"
gem "jbuilder", "~> 2.0"
gem "sdoc", "~> 0.4.0", group: :doc
gem "haml", ">= 3.0.0"
gem "haml-rails"

group :development, :test do
  gem "heroku_san"
  gem "byebug"
  gem "rspec-rails", ">= 2.0.1"
  gem "shoulda-matchers"
  gem "factory_girl_rails"
  gem "database_cleaner", require: false
  gem "faker"
end

group :development do
  gem "web-console", "~> 2.0"
  gem "spring"
end
