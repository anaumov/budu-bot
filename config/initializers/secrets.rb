# frozen_string_literal: true

Secrets = # rubocop:disable Naming/ConstantName
  if Rails.env.production?
    Rails.application.credentials
  else
    Rails.application.secrets
  end
