# frozen_string_literal: true

class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include TelegramUserConcern
  include TelegramCallbacksConcern
  include TelegramCommandsConcern

  def start!(*)
    message = "Привет, #{current_user.first_name}! Я — Продолжаю-бот. Я буду напоминать вам "\
              'о приеме лекарств и помогу следить за изменением вирусной нагрузки и иммунного '\
              'статуса. Подробнее обо мне https://продолжаю.рф'
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
    # service = GraphService.new(current_user)
    # respond_with :photo, photo: service.render_image(:immune_status)
    # respond_with :photo, photo: service.render_image(:viral_load)
    respond_with :photo, photo: File.open(File.join(Rails.root, 'viral_load_demo.png'))
    respond_with :photo, photo: File.open(File.join(Rails.root, 'immune_status_demo.png'))
  end

  def test!(*)
    service = GraphService.new(current_user)
    respond_with :photo, photo: service.render_image(:immune_status)
  end

  def setup!(*)
    setup_notifications
  end

  def help!(*)
    message = "Как внести результаты анализов:\n"\
              "Если ваша вирусная нагрузка равна 0 на 12 апреля 2017 года, напишите мне сообщение «вирусная нагрузка 0 12.04.2017» или в сокращенном варианте — «вн 0 12.04.2017».\n" \
              "Если ваш иммунный статус — 440 на 12 апреля 2017 года, напишите мне сообщение «иммунный статус 440 12.04.2017» или «ис 440 12.04.2017».\n\n" \
              "Настроить напоминания о приеме лекарств — /setup\n" \
              "Посмотреть изменения иммунного статуса и вирусной нагрузки в виде графиков — /graph.\n" \
              "Результаты анализов в виде таблицы — /table.\n"
    respond_with :message, text: message, parse_mode: :Markdown
  end

  def message(message)
    test_result = TestResultsFactory.new(current_user, message['text']).create_test_result!
    if test_result
      respond_with :message, text: "Записал. #{test_result.ru_result_type.capitalize} #{test_result.value} на #{test_result.date.strftime('%d.%m.%Y')}.", reply_markup: {
        inline_keyboard: [
          [
            { text: 'Ок, покажи график.', callback_data: "show_graph:#{test_result.result_type}" },
            { text: 'Нет, удали запись.', callback_data: "remove_test_result:#{test_result.id}" }
          ]
        ]
      }
    else
      respond_with :message, text: 'Не могу распознать сообщение. Посмотрите примеры с помощью команды /help.'
    end
  end

  def callback_query(data)
    parse_callback_data_and_response(data)
  end

  def action_missing(action)
    reply_with :message, text: "Упс, не знаю такой команды #{action}." if command?
  end
end
