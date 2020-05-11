# frozen_string_literal: true

class AddUndoneMessage < ActiveRecord::Migration[6.0]
  def up
    Message.create(
      slug: :undone,
      desc: 'Когда не ответил на сообщения',
      text: 'Автоматическая запись: пропуск терапии.'
    )
    Message.find_by!(slug: :daily_four).update(slug: :daily_undone)
  end
end
