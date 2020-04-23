# frozen_string_literal: true

class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include TelegramUserConcern
  include TelegramCallbacksConcern
  include TelegramCommandsConcern

  def start!(*)
    message = "Привет, #{current_user.first_name}! Я продолжаю-бот, я буду напоминать тебе каждый день о приеме лекарств и помогу следить за иммунным статусом и вирусной нагрузкой."
    if current_user.notification_set?
      respond_with :message, text: message
    else
      setup_notifications(message)
    end
  end

  def table!(*)
    message = "Дата       ВН         CD4\n"
    current_user.test_results.order(date: :asc).group_by(&:date).each do |date, results|
      immune_status = results.find(&:immune_status?)
      viral_load = results.find(&:viral_load?).value.to_s
      viral_load = viral_load.size < 6 ? (viral_load + ' ' * 2 * (6 - viral_load.size)) : viral_load
      message += "#{date.strftime('%d.%m.%y')}  #{viral_load}  #{immune_status&.value}\n"
    end
    respond_with :message, text: message
  end

  def setup!(*)
    setup_notifications
  end

  def message(message)
    test_result = TestResultsFactory.new(current_user).create_from_message(message)
    respond_with :message, text: "Записал. #{test_result.ru_result_type.capitalize} #{test_result.value} на #{test_result.date}.", reply_markup: {
      inline_keyboard: [
        [
          { text: 'Ок, покажи график.', callback_data: "show_graph:#{test_result.result_type}" },
          { text: 'Нет, удали запись.', callback_data: "remove_test_result:#{test_result.id}" }
        ]
      ]
    }
    # send graph with delay
  end

  def callback_query(data)
    parse_callback_data_and_response(data)
  end

  def action_missing(action)
    reply_with :message, text: "Упс, не знаю такой команды #{action}." if command?
  end
end
