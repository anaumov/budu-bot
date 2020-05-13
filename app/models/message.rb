# frozen_string_literal: true

class Message < ApplicationRecord
  scope :ordered, -> { order(id: :desc) }

  def self.build(slug, **args)
    message = find_by!(slug: slug)
    I18n.interpolate(message.text, **args)
  end

  def self.test_result_message(results)
    report = results.map do |result|
      result_message = if result[:result].present?
                         "сохранено #{result[:result].message_view}"
                       else
                         'не удалось распознать'
                       end
      "#{result[:message]} - #{result_message}"
    end
    build(:result_saved, report: report.join("\n"))
  end
end
