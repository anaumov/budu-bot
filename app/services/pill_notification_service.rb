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
    notify_undone_message
    undone_and_notify
  end

  private

  attr_reader :current_hour

  def notify_current_hour
    send_messages(users: users_to_be_notified, message_slug: :daily_first)
  end

  def notify_prev_hour
    send_messages(users: users_to_be_notified(hour_ago: 1), message_slug: :daily_second)
  end

  def notify_undone_message
    send_messages(users: users_to_be_notified(hour_ago: 2), message_slug: :daily_undone)
  end

  def undone_and_notify
    users = users_to_be_notified(hour_ago: 3)
    send_messages(users: users, message_slug: :undone)
    users.each(&:pill_undone!)
  end

  def send_messages(users:, message_slug:)
    return if users.empty?

    message = Message.build(message_slug, greeting: greeting)
    buttons = buttons_for(message_slug)
    users.each do |user|
      remove_buttons_for(user)
      send_notification(user: user, message: message, buttons: buttons)
    end
  end

  def remove_buttons_for(user)
    return unless user.last_notification_message_id

    Telegram.bot.edit_message_reply_markup(
      chat_id: user.telegram_chat_id,
      message_id: user.last_notification_message_id
    )
  rescue Telegram::Bot::Error, Telegram::Bot::Forbidden => e
    Bugsnag.notify(e) do |report|
      report.add_tab('User info', { id: user.id, message_id: user.last_notification_message_id })
    end
  end

  def send_notification(user:, message:, buttons:)
    response = Telegram.bot.send_message(
      chat_id: user.telegram_chat_id,
      text: message,
      reply_markup: { inline_keyboard: [buttons] }
    )
    user.update!(last_notification_message_id: response&.dig('result', 'message_id'))
  end

  def users_to_be_notified(hour_ago: 0)
    User.where(notification_time: current_hour - hour_ago)
        .select { |user| user.user_actions.today.empty? }
        .select { |user| bot_not_blocked_by(user) }
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

  def buttons_for(message_slug)
    if message_slug == :undone
      []
    else
      [{ text: '✅', callback_data: 'daily_pill:yes' }, { text: '❌', callback_data: 'daily_pill:no' }]
    end
  end

  def bot_not_blocked_by(user)
    Telegram.bot.send_chat_action(chat_id: user.telegram_chat_id, action: 'typing')
    true
  rescue Telegram::Bot::Forbidden
    user.update!(notification_time: nil)
    false
  end
end
