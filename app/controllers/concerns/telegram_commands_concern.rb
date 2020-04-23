# frozen_string_literal: true

module TelegramCommandsConcern
  private

  def setup_notifications(init_message = '')
    message = 'Когда вам нужно принимать лекарства?'
    buttons = [
      { text: 'Утром', callback_data: 'notifications_setup:morning' },
      { text: 'Вечером', callback_data: 'notifications_setup:evening' }
    ]
    if current_user.notification_set?
      message = "Сейчас я напоминаю вам о приеме лекарств ровно в #{current_user.notification_time}:00. Хотите поменять время?"
      buttons.push({ text: 'Выключить напоминания', callback_data: 'notifications_setup:turn_off' })
    end
    message = init_message + "\n" + message if init_message.present?
    respond_with :message, text: message, reply_markup: { inline_keyboard: [buttons] }
  end
end
