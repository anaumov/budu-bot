# frozen_string_literal: true

module TelegramCallbacksConcern
  ALLOWED_ACTIONS = %w[remove_test_result notifications_setup set_notification daily_pill].freeze

  def parse_callback_data_and_response(data)
    @action, @value = data.split(':')
    if valid_action?
      send(action)
    else
      send_message(Message.build(:something_went_wrong))
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
    send_message(message)
  end

  def remove_test_result
    current_user.test_results.find(value).destroy
    remove_buttons!
    send_message('Удалил')
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
      send_message(Message.build(:turned_off_notifications))
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
    send_message(Message.build(:notifications_set, time: "#{current_user.notification_time}:00"))
  end

  def valid_action?
    ALLOWED_ACTIONS.include?(action)
  end
end
