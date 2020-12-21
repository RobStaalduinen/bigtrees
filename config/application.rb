require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Bigtrees
  class Application < Rails::Application

    Rails.application.config.assets.precompile += %w( jquery-1.11.3.js pdf_styles.css )

    Rails.application.config.autoload_paths += Dir[Rails.root.join('lib')]
    Rails.application.config.autoload_paths += Dir[Rails.root.join('lib', "{*/}")]

    Rails.application.config.eager_load_paths +=  Dir[Rails.root.join('lib')]
    Rails.application.config.eager_load_paths +=  Dir[Rails.root.join('lib', "{*/}")]

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.active_job.queue_adapter = :delayed_job

    ActiveModelSerializers.config.adapter = :json
    ActiveModelSerializers.config.default_includes = '**'
  end
end
