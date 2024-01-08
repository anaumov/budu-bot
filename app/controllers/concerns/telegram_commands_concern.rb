# frozen_string_literal: true

module TelegramCommandsConcern
  def start!(*)
    message = Message.build(:on_start, name: current_user.first_name)
    send_message(
      text: message,
      buttons: [[
        { text: Button.get(:notifications_setup), callback_data: 'setup_noty' },
        { text: Button.get(:results_instruction), callback_data: 'results_info' }
      ]]
    )
  end

  def table!(*)
    if current_user.test_results.empty?
      send_message(text: Message.build(:no_test_results))
      return
    end

    message = MessagesService.formatted_table(current_user)
    respond_with :message, text: "<pre>#{message}</pre>", parse_mode: :HTML
    export_file = TestResultsExportService.perform(current_user)
    respond_with :document, document: export_file
    File.delete(export_file.path) if File.exist?(export_file.path)
  end

  def graph!(*)
    if current_user.test_results.any?
      respond_with_graph
    else
      send_message(text: Message.build(:no_test_results))
    end
  end

  def setup!(*)
    setup_notifications
  end

  def help!(*)
    send_message(text: Message.build(:help))
  end

  def unsafe_remove_all!(*)
    send_message(text: MessagesService.plain_table(current_user))
    current_user.test_results.destroy_all
    send_message(text: 'Все записи удалены')
  end

  def action_missing(action, *args)
    send_message(text: Message.build(:unknown_command, command: action))
    Bugsnag.notify('Action missing') do |report|
      report.severity = 'warning'
      report.add_tab('Telegram request', { action: action, args: args })
    end
  end

  private

  def setup_notifications(init_message = '')
    message = Message.build(:init_notifications_setup)
    buttons = Bot::ButtonsBuilder.hour_buttons(7, 12)
    if current_user.notification_set?
      message = Message.build(:notifications_setup, time: "#{current_user.notification_time}:00")
      buttons << [{ text: Button.get(:turn_off_notifications), callback_data: 'turn_off_notifications' }]
    end
    message = "#{init_message}\n#{message}" if init_message.present?
    send_message(text: message, buttons: buttons)
  end
end
