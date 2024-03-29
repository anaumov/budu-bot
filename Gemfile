source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rails', '~> 6.1.5'
gem 'puma', '~> 4.3'
gem 'sass-rails', '>= 6'
gem 'webpacker'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.7'
gem 'pg'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false
gem 'telegram-bot'
gem 'telegram-bot-types'

gem 'devise'
gem 'whenever', require: false
gem 'imgkit'

gem 'bootstrap'
gem 'slim'
gem 'kaminari'
gem 'kramdown'
gem 'simple_form'
gem 'bugsnag'
gem 'russian'
gem 'terminal-table'
gem 'attr_encrypted'

group :development, :test do
  gem 'database_rewinder'
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'pry'
  gem 'pry-rails'
  gem 'timecop'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
  gem 'overcommit', require: false

  # Deploy with capistrano
  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
  gem 'capistrano-rbenv'
  gem 'capistrano3-puma'
  gem 'capistrano-rails-console'
  gem 'capistrano-rails-tail-log'
  gem 'capistrano-db-tasks', require: false
  gem 'capistrano-shell', require: false
  gem 'capistrano3-delayed-job', '~> 1.0'
  gem 'capistrano-sidekiq', require: false
  gem 'capistrano-local-precompile', require: false
  gem 'sshkit-sudo'

  gem 'semver2'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
