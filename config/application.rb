require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module RailsTutorial
  class Application < Rails::Application
    config.load_defaults 7.0
    config.time_zone = Settings.time_zone
    config.active_record.default_timezone = :local
    config.active_storage.variant_processor = :mini_magick
    # Config i18n
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.i18n.available_locales = [:en, :vi]
    config.i18n.default_locale = :vi
    config.middleware.use I18n::JS::Middleware
  end
end
