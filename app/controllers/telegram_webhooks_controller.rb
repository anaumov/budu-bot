# frozen_string_literal: true

class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include TelegramMessageHelper
  include TelegramUserConcern
  include TelegramCallbacksConcern
  include TelegramCommandsConcern
  include TelegramGraphConcern
  include TelegramRescueConcern

  def message(message)
    result = MessageParserService.perform(message['text'], current_user)
    send_message(text: result[:message], buttons: result[:buttons])
    respond_with_graph if current_user.test_results.any?
  end
end
