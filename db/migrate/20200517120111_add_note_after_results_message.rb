# frozen_string_literal: true

class AddNoteAfterResultsMessage < ActiveRecord::Migration[6.0]
  def change
    Message.create(
      slug: :message_parse_success,
      desc: 'Если данные удалось распознать',
      text: "\n\nЕсли вы ошиблись при вводе данныx, нажмите ❌. Бот удалит все данные, которые вы ввели в этом сообщении."
    )
  end
end
