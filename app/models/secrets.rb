# frozen_string_liteal: true

Secrets =
  if Rails.env.production?
    Rails.application.credentials
  else
    Rails.application.secrets
  end
