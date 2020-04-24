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

  def results_as_table
    return 'Вы еще не внесли данные.' if current_user.test_results.empty?

    "Дата       ВН         CD4\n" \
    "#{build_table}"
  end

  def build_table
    result = ''
    current_user.test_results.order(date: :asc).group_by(&:date).each do |date, results|
      immune_status = results.find(&:immune_status?)
      viral_load = results.find(&:viral_load?)&.value&.to_s || ''
      viral_load = viral_load.size < 6 ? (viral_load + ' ' * 2 * (6 - viral_load.size)) : viral_load
      result += "#{date.strftime('%d.%m.%y')}  #{viral_load}  #{immune_status&.value}\n"
    end
    result
  end
end
