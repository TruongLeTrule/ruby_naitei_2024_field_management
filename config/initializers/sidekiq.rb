require "sidekiq/api"
require "sidekiq"
require "sidekiq-status"

Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV["REDIS"]
  }
  Sidekiq::Status.configure_server_middleware config
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV["REDIS"]
  }
  Sidekiq::Status.configure_client_middleware config
end
