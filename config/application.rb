require_relative "boot"

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require_relative '../lib/hash.rb'
require_relative '../lib/authentication.rb'

module PosterShop
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    config.active_job.queue_adapter = :delayed_job

    # Register warden for authentication middleware
    Warden::Strategies.add(:pwd, Authentication::Password)
    Warden::Strategies.add(:jwt, Authentication::JsonWebToken)
    
    config.middleware.use Warden::Manager do |manager|
      manager.default_strategies :pwd, :jwt
      manager.failure_app = ->(env){ Authentication::FailureApp.action(:index).call(env) }
    end
  end
end
