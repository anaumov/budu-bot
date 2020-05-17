# frozen_string_literal: true

module TelegramMessageHelper
  private

  def send_message(text:, buttons: [])
    respond_with :message, text: text, parse_mode: :Markdown, reply_markup: { inline_keyboard: buttons }
  end

  def remove_buttons!
    edit_message :reply_markup, reply_markup: { inline_keyboard: [] }
  end
end
