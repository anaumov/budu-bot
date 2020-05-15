# frozen_string_literal: true

class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include TelegramMessageConcern
  include TelegramUserConcern
  include TelegramCallbacksConcern
  include TelegramCommandsConcern
  include TelegramGraphConcern

  def start!(*)
    message = Message.build(:on_start, name: current_user.first_name)
    respond_with :message, text: message, reply_markup: {
      inline_keyboard: [[
        { text: 'напоминания', callback_data: 'setup_noty' },
        { text: 'результаты', callback_data: 'results_info' },
        { text: 'не сейчас', callback_data: 'not_now' }
      ]]
    }
  end

  def table!(*)
    if current_user.test_results.any?
      message = MessagesService.results_as_table(current_user)
      respond_with :message, text: "<pre>#{message}</pre>", parse_mode: :HTML
      export_file = TestResultsExportService.perform(current_user)
      respond_with :document, document: export_file
      File.delete(export_file.path) if File.exist?(export_file.path)
    else
      send_message Message.build(:no_test_results)
    end
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

  def unsafe_remove_all!(*)
    send_message(MessagesService.results_as_table(current_user))
    current_user.test_results.destroy_all
    respond_with :message, text: 'Все записи удалены'
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
