# frozen_string_literal: true

module TelegramCallbacksConcern
  ALLOWED_ACTIONS = %w[
    remove_test_result turn_off_notifications set_notification daily_pill
    setup_noty results_info not_now hour_buttons
  ].freeze

  def callback_query(data)
    @action, @value = data.split(':')
    if valid_action?
      send(action)
    else
      send_message(text: Message.build(:something_went_wrong))
    end
  end

  private

  attr_reader :action, :value

  def daily_pill
    message = Message.build(:something_went_wrong)
    if value == 'yes'
      message = Message.build(:pill_done)
      current_user.pill_done!
    elsif value == 'no'
      message = Message.build(:pill_undone)
      current_user.pill_undone!
    end

    remove_buttons!
    send_message(text: message)
  end

  def remove_test_result
    from, to = value.split('-').map(&:to_i)
    range = from.present? && to.present? ? (from..to) : from
    current_user.test_results.where(id: range).destroy_all
    remove_buttons!
    send_message(text: 'Удалено')
  end

  def hour_buttons
    from, to = value.split('..').map(&:to_i)
    buttons = Bot::ButtonsBuilder.hour_buttons(from, to)
    buttons << [{ text: Button.get(:turn_off_notifications), callback_data: 'turn_off_notifications' }] if current_user.notification_set?
    edit_message :reply_markup, reply_markup: { inline_keyboard: buttons }
  end

  def turn_off_notifications
    current_user.turn_off_notifications!
    remove_buttons!
    send_message(text: Message.build(:turned_off_notifications))
  end

  def set_notification
    current_user.set_notification_time!(value)
    remove_buttons!
    send_message(text: Message.build(:notifications_set, time: "#{current_user.notification_time}:00"))
  end

  def setup_noty
    hide_keyboard
    setup_notifications
  end

  def results_info
    hide_keyboard
    send_message(text: Message.build(:notifications_info))
  end

  def hide_keyboard
    edit_message :reply_markup, reply_markup: { inline_keyboard: [] }
  end

  def valid_action?
    ALLOWED_ACTIONS.include?(action)
  end
end
