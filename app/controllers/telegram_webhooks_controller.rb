# frozen_string_literal: true

class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include TelegramMessageConcern
  include TelegramUserConcern
  include TelegramCallbacksConcern
  include TelegramCommandsConcern
  include TelegramGraphConcern

  def start!(*)
    message = Message.build(:on_start, name: current_user.first_name)
    if current_user.notification_set?
      send_message(message)
    else
      setup_notifications(message)
    end
  end

  def table!(*)
    send_message(results_as_table)
  end

  def graph!(*)
    if current_user.test_results.empty?
      send_message(Message.build(:no_test_results))
      return
    end

    immune_status_graph
    viral_load_graph
  rescue StandardError => e
    Bugsnag.notify(e) if Rails.env.production?
    send_message(Message.build(:something_went_wrong))
  end

  def setup!(*)
    setup_notifications
  end

  def help!(*)
    send_message(Message.build(:help))
  end

  def message(message)
    test_result = TestResultsFactory.new(current_user, message['text']).create_test_result!
    if test_result
      message = Message.build(
        :result_saved,
        result_type: test_result.ru_result_type.capitalize,
        value: test_result.value,
        date: test_result.date.strftime('%d.%m.%Y')
      )
      send("#{test_result.result_type}_graph")
      respond_with :message, text: message, reply_markup: {
        inline_keyboard: [[
          { text: 'Удали запись', callback_data: "remove_test_result:#{test_result.id}" }
        ]]
      }
    else
      send_message(Message.build(:cant_recognise))
    end
  end

  def callback_query(data)
    parse_callback_data_and_response(data)
  end

  def action_missing(action)
    send_message(Message.build(:unknown_command, command: action)) if command?
  end
end
