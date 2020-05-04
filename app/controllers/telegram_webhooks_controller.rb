# frozen_string_literal: true

class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include TelegramMessageConcern
  include TelegramUserConcern
  include TelegramCallbacksConcern
  include TelegramCommandsConcern

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

  # rubocop:disable Metrics/AbcSize
  def graph!(*)
    if current_user.test_results.empty?
      send_message(Message.build(:no_test_results))
      return
    end

    service = GraphService.new(current_user)
    immune_status_graph = service.render_image(:immune_status)
    send_message('Иммунный статус')
    respond_with :photo, photo: immune_status_graph
    File.delete(immune_status_graph.path) if File.exist?(immune_status_graph.path)

    viral_load_graph = service.render_image(:viral_load)
    send_message('Вирусная нагрузка')
    respond_with :photo, photo: viral_load_graph
    File.delete(viral_load_graph.path) if File.exist?(viral_load_graph.path)
  rescue StandardError => e
    Bugsnag.notify(e) if Rails.env.production?
    send_message(Message.build(:something_went_wrong))
  end
  # rubocop:enable Metrics/AbcSize

  def setup!(*)
    setup_notifications
  end

  def help!(*)
    send_message(Message.build(:help))
  end

  def callback_query(data)
    parse_callback_data_and_response(data)
  end

  def action_missing(action)
    send_message(Message.build(:unknown_command, command: action)) if command?
  end
end
