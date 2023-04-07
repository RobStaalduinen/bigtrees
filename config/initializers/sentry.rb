Sentry.init do |config|
  config.dsn = 'https://8800ecb88dc445d48a4b25f28b1c4e7c@o575740.ingest.sentry.io/5728428'
  config.enabled_environments = %w[production]
  # Set traces_sample_rate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production.
  config.traces_sample_rate = 1.0
  # or
  config.traces_sampler = lambda do |context|
    true
  end
end
