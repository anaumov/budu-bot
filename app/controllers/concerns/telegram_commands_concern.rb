# frozen_string_literal: true

module TelegramCommandsConcern
  private

  def setup_notifications(init_message = '')
    message = Message.build(:init_notifications_setup)
    buttons = [
      { text: 'Утром', callback_data: 'notifications_setup:morning' },
      { text: 'Вечером', callback_data: 'notifications_setup:evening' }
    ]
    if current_user.notification_set?
      message = Message.build(:notifications_setup, time: "#{current_user.notification_time}:00")
      buttons.push({ text: 'Выключить напоминания', callback_data: 'notifications_setup:turn_off' })
    end
    message = init_message + "\n" + message if init_message.present?
    respond_with :message, text: message, reply_markup: { inline_keyboard: [buttons] }
  end
end
