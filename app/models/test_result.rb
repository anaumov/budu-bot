# frozen_string_literal: true

class TestResult < ApplicationRecord
  belongs_to :user
  enum result_type: %i[viral_load immune_status]
  scope :ordered, -> { order(date: :asc) }

  def self.to_message(test_results)
    if test_results.size > 1
      message = test_results.map { |tr| "#{tr.ru_result_type} – #{tr.value}" }.join(', ')
      message += " на #{test_results.first.dec_date}"
      message
    else
      test_results.first.message_view
    end.capitalize
  end

  def ru_result_type
    I18n.t(result_type, scope: %i[test_result result_type])
  end

  def dec_date
    I18n.l(date, format: '%d.%m.%Y')
  end

  def message_view
    "#{ru_result_type} #{value} на #{dec_date}"
  end
end
