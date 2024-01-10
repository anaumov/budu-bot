# frozen_string_literal: true

namespace :notification do
  desc 'Send hourly notifications'
  task hourly: :environment do
    PillNotificationService.notify_users
  end

  task naumov: :environment do
    PillNotificationService.new.notify_naumov
  end
end
