# frozen_string_literal: true

class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include TelegramMessageHelper
  include TelegramUserConcern
  include TelegramCallbacksConcern
  include TelegramCommandsConcern
  include TelegramGraphConcern
  include TelegramRescueConcern

  def message(message)
    results = TestResultsFactory.perform(current_user, message['text'])
    message = Message.test_result_message(results)
    ids = results.map { |el| el[:result]&.id }.compact
    # FIXME: add desc about what is going to be removed
    buttons = [[
      { text: 'Отменить', callback_data: "remove_test_result:#{ids.first}-#{ids.last}}" }
    ]]
    send_message(text: message, buttons: buttons)
    respond_with_graph if current_user.test_results.any?
  end
end
