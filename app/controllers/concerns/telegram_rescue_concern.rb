# frozen_string_literal: true

module TelegramRescueConcern
  private

  def process_action(*args)
    super
  rescue StandardError => e
    raise e unless Rails.env.production?

    Bugsnag.notify(e)
    send_message(text: Message.build(:something_went_wrong))
  end
end
