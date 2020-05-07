# frozen_string_literal: true

Bugsnag.configure do |config|
  config.api_key = Secrets[:bugsnag_api_key]
  config.notify_release_stages = %w[staging production]
end
