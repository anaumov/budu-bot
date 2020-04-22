# frozen_string_literal: true

class NotificationService
  def self.notify_users
    # FIXME: use user timezone
    current_hour = Time.zone.now.hour
    greeting = current_hour < 13 ? 'Доброе утро!' : 'Добрый вечер!'
    message = "#{greeting} Не забудь принять лекарства. Сообщи мне, пожалуйста, когда выпьешь."
    buttons = [
      { text: 'Принял! 💪', callback_data: 'daily_pill:yes' },
      { text: 'Не принял', callback_data: 'daily_pill:no' }
    ]
    User.where(notification_time: current_hour).each do |user|
      Telegram.bot.send_message(
        chat_id: user.telegram_chat_id,
        text: message,
        reply_markup: { inline_keyboard: [buttons] }
      )
    end
  end
end
