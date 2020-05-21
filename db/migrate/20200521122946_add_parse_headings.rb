# frozen_string_literal: true

class AddParseHeadings < ActiveRecord::Migration[6.0]
  def up
    Message.find_by(slug: :parse_title).update(slug: :parse_success, desc: 'Все данные распознаны')
    Message.find_by(slug: :message_parse_success).update(slug: :remove_data_note)

    messages = [
      {
        slug: :parse_fail,
        desc: 'Ничего не распознано',
        text: "*❗️ Данные не сохранены*\n"
      },
      {
        slug: :parse_has_errors,
        desc: 'Часть распознано, часть нет',
        text: "*❗️ Некоторые данные не сохранены*\n"
      },
      {
        slug: :how_to_register_dupe,
        desc: 'После того как ничего не удалось распознать',
        text: 'Посмотрите еще раз как можно добавить данные:'
      }
    ]
    messages.each { |m| Message.create(m) }
  end
end
