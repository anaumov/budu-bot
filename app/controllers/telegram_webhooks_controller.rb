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
    respond_with :message, text: results_as_table
  end

  def graph!(*)
    respond_with :photo, photo: File.open(File.join(Rails.root, 'viral_load_demo.png'))
    respond_with :photo, photo: File.open(File.join(Rails.root, 'immune_status_demo.png'))
  end

  def setup!(*)
    setup_notifications
  end

  def help!(*)
    message = "Как работать с ботом?\n"\
              "/setup — настроить ежедневные уведомления о примеме лекарств.\n" \
              "Получить днные изменения иммунного статуса и вирусной нагрузки в виде графиков — /graph, в виде таблицы — /table.\n\n" \
              "*Внесение результатов анализов*\n" \
              "Пришлите сообщение «вирусная нагрузка 0 12.04.2017». Я пойму, что ваша вирусная нагрузка на 12 апреля 2017 года равна 0.\n" \
              "Пришлите сообщение «иммунный статус 440 12.04.2017». Я пойму, что ваш иммунный статус на 12 апреля 2017 года равен 440.\n" \
              "Также можно в сокращенном виде: «вн 0 12.04.2017» и «ис 440 12.04.2017».\n"
    respond_with :message, text: message, parse_mode: :Markdown
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
