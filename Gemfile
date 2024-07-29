source "https://rubygems.org"
git_source(:github){|repo| "https://github.com/#{repo}.git"}

ruby "3.2.2"
gem "bcrypt", "3.1.18"
gem "bootsnap", require: false
gem "config"
gem "faker"
gem "figaro"
gem "font-awesome-rails"
gem "i18n-js", "3.8.0"
gem "importmap-rails"
gem "jbuilder"
gem "mysql2", "~> 0.5"
gem "pagy", "~> 9.0"
gem "puma", "~> 5.0"
gem "rails", "~> 7.0.5"
gem "rails-i18n"
gem "sassc-rails"
gem "sprockets-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "turbo-rails"
gem "tzinfo-data", platforms: %i(mingw mswin x64_mingw jruby)

group :development, :test do
  gem "debug", platforms: %i(mri mingw x64_mingw)
  gem "rspec-rails", "~> 5.0.0"
  gem "rubocop", "~> 1.26", require: false
  gem "rubocop-checkstyle_formatter", require: false
  gem "rubocop-rails", "~> 2.14.0", require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end
