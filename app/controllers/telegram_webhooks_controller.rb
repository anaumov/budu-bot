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
    message = if current_user.test_results.any?
                MessagesService.results_as_table(current_user)
              else
                Message.build(:no_test_results)
              end

    send_message(message)
  end

  def graph!(*)
    if current_user.test_results.any?
      respond_with_graph
    else
      send_message(Message.build(:no_test_results))
    end
  rescue StandardError => e
    Bugsnag.notify(e) if Rails.env.production?
    raise e if Rails.env.development?

    send_message(Message.build(:something_went_wrong))
  end

  def setup!(*)
    setup_notifications
  end

  def help!(*)
    send_message(Message.build(:help))
  end

  def message(message)
    results = TestResultsFactory.perform(current_user, message['text'])
    message = Message.test_result_message(results)
    ids = results.map { |el| el[:result]&.id }.compact
    respond_with :message, text: message, reply_markup: {
      inline_keyboard: [[
        { text: 'Отменить запись', callback_data: "remove_test_result:#{ids.first}-#{ids.last}}" }
      ]]
    }
    respond_with_graph
  end

  def callback_query(data)
    parse_callback_data_and_response(data)
  end

  def action_missing(action, *args)
    send_message(Message.build(:unknown_command, command: action))
    Bugsnag.notify('Action missing') do |report|
      report.severity = 'warning'
      report.add_tab('Telegram request', { action: action, args: args })
    end
  end
end
