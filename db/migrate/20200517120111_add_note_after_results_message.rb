# frozen_string_literal: true

class AddNoteAfterResultsMessage < ActiveRecord::Migration[6.0]
  def change
    Message.create(
      slug: :message_parse_success,
      desc: 'Если данные удалось распознать',
      text: "\n\nЕсли вы видите, что ошиблись при вводе данные, нажмите ❌. Бот удалит введенные данные."
    )
  end
end
