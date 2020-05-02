# frozen_string_literal: true

class MoreMessages < ActiveRecord::Migration[6.0]
  def change
    messages = [
      {
        slug: :daily_first,
        desc: 'Первое напоминание о приеме лекарств',
        text: '%{greeting}! Не забудьте принять лекарства. Сообщите мне, пожалуйста, когда примете.'
      },
      {
        slug: :daily_second,
        desc: 'Второе напоминание о приеме лекарств',
        text: 'Хочу еще раз напомнить о приеме. Жду ответа.'
      },
      {
        slug: :daily_third,
        desc: 'Третье напоминание о приеме лекарств',
        text: 'Вы мне так и не написали, я беспокоюсь. Приняли лекарство?'
      },
      {
        slug: :daily_four,
        desc: 'Четвертое напоминание о приеме лекарств',
        text: 'Я еще здесь. Через час я запишу, что вы не выпили лекарства. Пожалуйста, не дайте мне этого сделать!'
      }
    ]
    messages.each { |m| Message.create(m) }
  end
end
