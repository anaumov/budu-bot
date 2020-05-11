# frozen_string_literal: true

class Message < ApplicationRecord
  scope :ordered, -> { order(id: :desc) }

  def self.build(slug, **args)
    message = find_by!(slug: slug)
    I18n.interpolate(message.text, **args)
  end

  def self.test_result_message(test_result)
    build(
      :result_saved,
      result_type: test_result.ru_result_type.capitalize,
      value: test_result.value,
      date: test_result.date.strftime('%d.%m.%Y')
    )
  end
end
