# frozen_string_literal: true

class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include TelegramMessageHelper
  include TelegramUserConcern
  include TelegramCallbacksConcern
  include TelegramCommandsConcern
  include TelegramGraphConcern
  include TelegramRescueConcern

  def message(message)
    return if current_user.inactive?

    result = MessageParserService.perform(message['text'], current_user)
    send_message(text: result[:message], buttons: result[:buttons])
    respond_with_graph unless result[:status] == :fail
  rescue Telegram::Bot::Forbidden
    current_user.deactivate!
  end
end
