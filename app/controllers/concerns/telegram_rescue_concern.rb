# frozen_string_literal: true

module TelegramRescueConcern
  private

  def process_action(*args)
    super
  rescue StandardError => e
    send_message(Message.build(:something_went_wrong))
    Bugsnag.notify(e)
    raise e unless Rails.env.production?
  end
end
