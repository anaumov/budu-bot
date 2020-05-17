# frozen_string_literal: true

module TelegramCallbacksConcern
  ALLOWED_ACTIONS = %w[
    remove_test_result notifications_setup set_notification daily_pill
    setup_noty results_info not_now
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

  def notifications_setup
    case value
    when 'morning'
      respond_with_times((7..12).to_a)
    when 'evening'
      respond_with_times((16..22).to_a)
    when 'turn_off'
      current_user.update!(notification_time: nil)
      remove_buttons!
      send_message(text: Message.build(:turned_off_notifications))
    else
      raise :err
    end
  end

  def respond_with_times(hours)
    edit_message :reply_markup, reply_markup: {
      inline_keyboard: buttons_by_hours(hours)
    }
  end

  def buttons_by_hours(hours)
    hour_to_button = ->(hour) { { text: "#{hour}:00", callback_data: "set_notification:#{hour}" } }
    [hours[0..2].map(&hour_to_button), hours[3..5].map(&hour_to_button)]
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
