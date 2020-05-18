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
    buttons = [[{ text: Button.get(:earlier), callback_data: "hour_buttons:#{from - 6}..#{from - 1}" }]]
    buttons += buttons_by_hours(from, to)
    buttons << [{ text: Button.get(:later), callback_data: "hour_buttons:#{to + 1}..#{to + 6}" }]
    edit_message :reply_markup, reply_markup: { inline_keyboard: buttons }
  end

  def turn_off_notifications
    current_user.update!(notification_time: nil)
    remove_buttons!
    send_message(text: Message.build(:turned_off_notifications))
  end

  def buttons_by_hours(from, to)
    hour_to_button = ->(hour) { [{ text: "#{hour}:00", callback_data: "set_notification:#{hour}" }] }
    build_range(from, to).to_a.map(&hour_to_button)
  end

  def build_range(from, to)
    (from..to).to_a.map do |hour|
      hour = hour % 24
      if hour > 23
        hour - 24
      elsif hour.negative?
        hour + 24
      else
        hour
      end
    end
  end

  def set_notification
    current_user.update!(notification_time: value)
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
