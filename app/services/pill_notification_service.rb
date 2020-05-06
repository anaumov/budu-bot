# frozen_string_literal: true

class PillNotificationService
  # FIXME: use user timezone
  def self.notify_users
    new(Time.zone.now.hour).notify_users
  end

  def initialize(current_hour)
    @current_hour = current_hour
  end

  def notify_users
    notify_current_hour
    notify_prev_hour
    nofity_prev_two_hours
    notify_prev_three_hours
    notify_undone_message
  end

  private

  attr_reader :current_hour

  def notify_current_hour
    send_messages(users: users_scope(0), message_slug: :daily_first)
  end

  def notify_prev_hour
    send_messages(users: users_scope(1), message_slug: :daily_second)
  end

  def nofity_prev_two_hours
    send_messages(users: users_scope(2), message_slug: :daily_third)
  end

  def notify_prev_three_hours
    send_messages(users: users_scope(3), message_slug: :daily_four)
  end

  def notify_undone_message
    send_messages(users: users_scope(4), message_slug: :daily_undone)
  end

  def send_messages(users:, message_slug:)
    return if users.empty?

    message = Message.build(message_slug, greeting: greeting)
    users.each do |user|
      remove_buttons_for(user)
      send_notification(user, message)
    end
  end

  def remove_buttons_for(user)
    return unless user.last_notification_message_id

    Telegram.bot.edit_message_reply_markup(
      chat_id: user.telegram_chat_id,
      message_id: user.last_notification_message_id
    )
  end

  def send_notification(user, message)
    response = Telegram.bot.send_message(
      chat_id: user.telegram_chat_id,
      text: message,
      reply_markup: { inline_keyboard: [buttons] }
    )
    user.update!(last_notification_message_id: response.dig('result', 'message_id'))
  end

  def users_scope(shift)
    User.where(notification_time: current_hour - shift)
        .select { |user| user.user_actions.today.empty? }
  end

  def greeting
    if current_hour < 5
      'Доброй ночи'
    elsif current_hour < 13
      'Доброе утро'
    elsif current_hour < 16
      'Добрый день'
    else
      'Добрый вечер'
    end
  end

  def buttons
    [
      { text: 'Принял! 💪', callback_data: 'daily_pill:yes' },
      { text: 'Не принял', callback_data: 'daily_pill:no' }
    ]
  end
end
