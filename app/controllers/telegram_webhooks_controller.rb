# frozen_string_literal: true

class TelegramWebhooksController < Telegram::Bot::UpdatesController
  def start!(*)
    respond_with :message, text: 'Привет! Я будубот, я буду напоминать тебе о приеме лекарств и помогу следить за иммунным статусом и вирусной нагрузкой.'
  end

  def message(_message)
    respond_with :message, text: "Ваша вирусная нагрузка 0 на #{Date.today}. Верно?", reply_markup: {
      inline_keyboard: [
        [
          { text: 'Да, верно!', callback_data: 'yes_vn' },
          { text: 'Нет', callback_data: 'nope' }
        ]
      ]
    }
  end

  def callback_query(data)
    puts data
    if data == 'yes_vn'
      respond_with :photo, photo: File.open(File.join(Rails.root, 'demo.png'))
    else
      answer_callback_query 'Ок, повторите запись'
    end
  end

  def action_missing(action)
    reply_with :message, text: "Упс, не знаю такой команды #{action}." if command?
  end
end
