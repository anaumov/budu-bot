# frozen_string_literal: true

module TelegramMessageConcern
  def message(message)
    test_result = TestResultsFactory.new(current_user, message['text']).create_test_result!
    unless test_result
      send_message(Message.build(:cant_recognise))
      return
    end

    message = Message.build(
      :result_saved,
      result_type: test_result.ru_result_type.capitalize,
      value: test_result.value,
      date: test_result.date.strftime('%d.%m.%Y')
    )
    respond_with :message, text: message, reply_markup: {
      inline_keyboard: [{ text: 'Отменить', callback_data: "remove_test_result:#{test_result.id}" }]
    }
  end

  private

  def send_message(text)
    respond_with :message, text: text, parse_mode: :Markdown
  end

  def remove_buttons!
    edit_message :reply_markup, reply_markup: { inline_keyboard: [] }
  end
end
