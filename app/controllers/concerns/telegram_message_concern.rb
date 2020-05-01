# frozen_string_literal: true

module TelegramMessageConcern
  def message(message)
    test_result = TestResultsFactory.new(current_user, message['text']).create_test_result!
    if test_result
      message = Message.build(
        :result_saved,
        result_type: test_result.ru_result_type.capitalize,
        value: test_result.value,
        date: test_result.date.strftime('%d.%m.%Y')
      )
      respond_with text: message, reply_markup: {
        inline_keyboard: [
          [
            { text: 'Ок, покажи график.', callback_data: "show_graph:#{test_result.result_type}" },
            { text: 'Нет, удали запись.', callback_data: "remove_test_result:#{test_result.id}" }
          ]
        ]
      }
    else
      send_message(Message.build(:cant_recognise))
    end
  end

  private

  def send_message(text)
    respond_with :message, text: text, parse_mode: :Markdown
  end

  def remove_buttons!
    edit_message :reply_markup, reply_markup: { inline_keyboard: [] }
  end
end
