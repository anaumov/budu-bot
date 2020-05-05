# frozen_string_literal: true

module TelegramMessageConcern
  private

  def send_message(text)
    respond_with :message, text: text, parse_mode: :Markdown
  end

  def remove_buttons!
    edit_message :reply_markup, reply_markup: { inline_keyboard: [] }
  end
end
