# frozen_string_literal: true

module TelegramCallbacksConcern
  ALLOWED_ACTIONS = %w[remove_test_result show_graph notifications_setup set_notification].freeze

  def parse_callback_data_and_response(data)
    @action, @value = data.split(':')
    if valid_action?
      send(action)
    else
      respond_with :message, text: 'Ой, что-то пошло не так. Мы разберемся и починим.'
    end
  end

  private

  attr_reader :action, :value

  def remove_test_result
    current_user.test_results.find(value).destroy
    respond_with :message, text: 'Удалил'
  end

  def show_graph
    respond_with :photo, photo: File.open(File.join(Rails.root, "#{value}_demo.png"))
  end

  def notifications_setup
    case value
    when 'morning'
      respond_with_times((6..12).to_a)
    when 'evening'
      respond_with_times((16..22).to_a)
    when 'turn_off'
      current_user.update!(notification_time: nil)
      respond_with :message, text: 'Выключил ежедневные уведомления.'
    else
      raise :err
    end
  end

  def respond_with_times(hours)
    respond_with :message, text: 'В какое время напоминать?', reply_markup: {
      inline_keyboard: [buttons_by_hours(hours)]
    }
  end

  def buttons_by_hours(hours)
    hours.map { |hour| { text: "#{hour}:00", callback_data: "set_notification:#{hour}" } }
  end

  def set_notification
    current_user.update!(notification_time: value)
    respond_with :message, text: "Я буду напоминать вам о приеме лекарств ровно в #{current_user.notification_time}:00."
  end

  def valid_action?
    ALLOWED_ACTIONS.include?(action)
  end
end
