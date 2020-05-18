# frozen_string_literal: true

class AddParseTitleMessage < ActiveRecord::Migration[6.0]
  def change
    Message.create(
      slug: :parse_title,
      desc: 'Заголовок результатов распознования сообщений',
      text: "*Результат распознования.*\nЕсли вы видите ✅ вначале строки – сообщение распозналось, если ❌ — нет.\n\n"
    )
  end
end
